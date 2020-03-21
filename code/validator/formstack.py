import os
import logging
import hmac
from flask import abort, request, Response

from validator.clients import ups
from typing import Optional

logger = logging.getLogger(__name__)

HANDSHAKE_KEY = os.getenv('HANDSHAKE_KEY', '')
HMAC_KEY = os.getenv('HMAC_KEY', '').encode('utf-8')

def hmac_valid(*, hmac_key: Optional[str] = None) -> bool:
    """Determine if the signature is valid for the request.
    
    :param hmac_key: The key to use to validate, will use module version if
        not present.
    :returns: True or false.
    """
    if hmac_key is None:
        hmac_key = HMAC_KEY
    sig = request.headers.get('X-FS-Signature')
    if not sig:
        return False
    # get_data could be huge, check content length?
    calc_sig = hmac.new(hmac_key, request.get_data(), 'sha256').hexdigest()
    return hmac.compare_digest(f'sha256={calc_sig}', sig)

def incoming():
    if not hmac_valid():
        return abort(Response('Invalid Signature', status=403))

    data = request.get_json()

    if data.get('HandshakeKey') != HANDSHAKE_KEY:
        err_txt = 'Invalid Handshake Key'
        logger.info(err_txt)
        return abort(Response(err_txt, status=403))

    address = data['Address']
    address_lines = [address['address']]
    region = f"{address['city']},{address['state']},{address['zip']}"
    try:
        request_body = ups.build_request_body(address_lines, region)
        is_valid = ups.address_valid(request_body)
    except ups.AmbiguousAddressError:
        return 'Ambiguous Address'
    except ups.APIFailure:
        return 'API Failure'

    return str(is_valid)
