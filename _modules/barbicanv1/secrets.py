try:
    from urllib.parse import urlencode
except ImportError:
    from urllib import urlencode

from barbicanv1.common import send, get_by_name_or_uuid

RESOURCE_LIST_KEY = 'secrets'


@send('get')
def secret_list(**kwargs):
    url = '/secrets?{}'.format(urlencode(kwargs))
    return url, {}


@send('post')
def secret_create(**kwargs):
    url = '/secrets'
    return url, {'json': kwargs}


@get_by_name_or_uuid(secret_list, RESOURCE_LIST_KEY)
@send('get')
def secret_get_details(secret_uuid, **kwargs):
    url = '/secrets/{}'.format(secret_uuid)
    return url, {}


@get_by_name_or_uuid(secret_list, RESOURCE_LIST_KEY)
@send('delete')
def secret_delete(secret_uuid, **kwargs):
    url = '/secrets/{}'.format(secret_uuid)
    return url, {}

# NOTE::
# ** payload get and sett requires headers passed in kwargs that describe
# ** content type of the payload


@get_by_name_or_uuid(secret_list, RESOURCE_LIST_KEY)
@send('put')
def secret_payload_set(secret_uuid, payload, **kwargs):
    url = '/secrets/{}'.format(secret_uuid)
    # Work around content headers
    content_type = 'payload_content_type'
    content_encoding = 'payload_content_encoding'
    headers = kwargs.get('headers', {})
    if content_type in kwargs:
        headers['Content-Type'] = kwargs[content_type]
        if content_type == 'application/octet-stream':
            headers['Content-Encoding'] = kwargs[content_encoding]

    return url, {'json': payload, 'headers': headers}


@get_by_name_or_uuid(secret_list, RESOURCE_LIST_KEY)
@send('get')
def secret_payload_get(secret_uuid, **kwargs):
    url = '/secrets/{}/payload'.format(secret_uuid)
    return url, {}
