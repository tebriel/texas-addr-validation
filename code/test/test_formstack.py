import hmac
from unittest import TestCase, skip

from flask import request
from validator import formstack

class TestFormstack(TestCase):
    @skip('not ready')
    def test_hmac_valid(self): 
        body = 'a-very-body'.encode('utf-8')
        key = 'very-secret-key'.encode('utf-8')
        sig = hmac.new(key, body, 'sha256').hexdigest()
        request.headers.set('X-FS-Signature', f'sha256={sig.hexdigest()}')
        request.data = body
        self.assertTrue(formstack.hmac_valid(hmac_key=key))
