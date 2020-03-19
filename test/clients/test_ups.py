from unittest import TestCase

from validator.clients import ups


class TestUps(TestCase):
    def test_build_request_body(self):
        address_lines = ['123 Main Street']
        region = 'City,State,123456'
        body = ups.build_request_body(address_lines, region)

        self.assertEqual(body['XAVRequest']['AddressKeyFormat']['AddressLine'], address_lines)
        self.assertEqual(body['XAVRequest']['AddressKeyFormat']['Region'], region)
