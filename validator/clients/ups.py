import os
import requests
from typing import Any, Dict, List

PROD_URL = 'https://onlinetools.ups.com/addressvalidation/v1/1'

_session = requests.session()
_session.headers = requests.structures.CaseInsensitiveDict(data={
    'Content-Type': 'application/json',
    'AccessLicenseNumber': os.getenv('UPS_LICENSE_NUMBER', ''),
    'Username': os.getenv('UPS_USERNAME', ''),
    'Password': os.getenv('UPS_PASSWORD', ''),
})

class AmbiguousAddressError(Exception):
    """If the UPS API says an address is ambiguous."""


class APIFailure(Exception):
    """If the API gave us a non-success response."""


def build_request_body(address_lines: List[str], region: str) -> Dict[str, Any]:
    """Build a request body for the UPS API.

    :param address_lines: List of address lines
    :param region: Everything else as 'city,state,zip'
    :returns: The UPS request body format.
    """
    return {
        "XAVRequest": {
            "AddressKeyFormat": {
                "AddressLine": address_lines,
                "Region": region,
                "CountryCode": "US"
                }
            }
        }


def address_valid(body: Dict[str, Any], session: requests.Session = None) -> bool:
    """Ask UPS if an address is valid.

    :param body: The properly formed UPS request body.
    :param session: A custom session (will default to the one in this module).
    :returns: Bool of if it's valid or not.
    :raises AmbiguousAddressError: if it couldn't get the exact address validated.
    :raises APIFailure: If we got an error back from the API
    :raises HTTPError: If we couldn't connect to the API
    """
    if not session:
        session = _session

    resp = session.post(body, timeout=5)

    resp.raise_for_status()

    resp_data = resp.json()

    xav_response = resp_data.get('XAVResponse', {})
    resp_status = xav_response.get('Response', {}).get('ResponseStatus', {})

    if resp_status.get('Code') != 1:
        raise APIFailure(resp_status.get('Description', 'UNKNOWN'))

    if xav_response.get('AmbiguousAddressIndicator') != None:
        raise AmbiguousAddressError()

    if xav_response.get('ValidAddressIndicator') != None:
        return True
    
    return False
