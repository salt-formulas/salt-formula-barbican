from barbicanv1.common import send, get_by_name_or_uuid
from barbicanv1.secrets import secret_list, RESOURCE_LIST_KEY


@get_by_name_or_uuid(secret_list, RESOURCE_LIST_KEY)
@send('get')
def secret_acl_get(secret_uuid, **kwargs):
    url = '/secrets/{}/acl'.format(secret_uuid)
    return url, {}


@get_by_name_or_uuid(secret_list, RESOURCE_LIST_KEY)
@send('put')
def secret_acl_put(secret_uuid, **kwargs):
    url = '/secrets/{}/acl'.format(secret_uuid)
    json = {
        'read': kwargs,
    }
    return url, {'json': json}


@get_by_name_or_uuid(secret_list, RESOURCE_LIST_KEY)
@send('patch')
def secret_acl_patch(secret_uuid, **kwargs):
    url = '/secrets/{}/acl'.format(secret_uuid)
    json = {
        'read': kwargs,
    }
    return url, {'json': json}


@get_by_name_or_uuid(secret_list, RESOURCE_LIST_KEY)
@send('delete')
def secret_acl_delete(secret_uuid, **kwargs):
    url = '/secrets/{}/acl'.format(secret_uuid)
    return url, {}
