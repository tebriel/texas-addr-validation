import json
from unittest import TestCase
from unittest.mock import Mock
import requests

from validator.clients import ups


class TestUps(TestCase):
    def test_build_request_body(self):
        address_lines = ['123 Main Street']
        region = 'City,State,123456'
        body = ups.build_request_body(address_lines, region)

        self.assertEqual(body['XAVRequest']['AddressKeyFormat']['AddressLine'], address_lines)
        self.assertEqual(body['XAVRequest']['AddressKeyFormat']['Region'], region)

    def test_address_valid__true(self):
        response = requests.Response()
        response.status_code = 200
        response._content = json.dumps({
            'XAVResponse': {
                'Response': {
                    'ResponseStatus': {
                        'Code': 1,
                        'Description': 'Success'
                    }
                },
                'ValidAddressIndicator': '',
            },
        }).encode('utf-8')
        session_mock = Mock(spec_set=requests.session())
        session_mock.post.return_value = response
        self.assertTrue(ups.address_valid(None, session_mock))

    def test_address_valid__failure(self):
        response = requests.Response()
        response.status_code = 200
        response._content = json.dumps({
            'XAVResponse': {
                'Response': {
                    'ResponseStatus': {
                        'Code': 2,
                        'Description': 'Failure'
                    }
                },
            },
        }).encode('utf-8')
        session_mock = Mock(spec_set=requests.session())
        session_mock.post.return_value = response
        self.assertRaises(
            ups.APIFailure,
            ups.address_valid,
            None,
            session_mock,
        )

    def test_address_valid__http_error(self):
        response = requests.Response()
        response.status_code = 500
        session_mock = Mock(spec_set=requests.session())
        session_mock.post.return_value = response
        self.assertRaises(
            requests.HTTPError,
            ups.address_valid,
            None,
            session_mock,
        )

    def test_address_valid__ambiguous(self):
        response = requests.Response()
        response.status_code = 200
        response._content = json.dumps({
            'XAVResponse': {
                'Response': {
                    'ResponseStatus': {
                        'Code': 1,
                        'Description': 'Success'
                    }
                },
                'AmbiguousAddressIndicator': '',
            },
        }).encode('utf-8')
        session_mock = Mock(spec_set=requests.session())
        session_mock.post.return_value = response
        self.assertRaises(
            ups.AmbiguousAddressError,
            ups.address_valid,
            None,
            session_mock,
        )
