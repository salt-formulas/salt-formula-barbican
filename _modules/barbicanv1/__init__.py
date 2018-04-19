try:
    import os_client_config
    from keystoneauth1 import exceptions as ka_exceptions
    REQUIREMENTS_MET = True
except ImportError:
    REQUIREMENTS_MET = False

from barbicanv1 import secrets
from barbicanv1 import acl

secret_list = secrets.secret_list
secret_create = secrets.secret_create
secret_delete = secrets.secret_delete
secret_get_details = secrets.secret_get_details
secret_payload_get = secrets.secret_payload_get
secret_payload_set = secrets.secret_payload_set
secret_acl_get = acl.secret_acl_get
secret_acl_put = acl.secret_acl_put
secret_acl_patch = acl.secret_acl_patch
secret_acl_delete = acl.secret_acl_delete

__all__ = (
    'secret_list', 'secret_create', 'secret_delete', 'secret_get_details',
    'secret_payload_get', 'secret_payload_set', 'secret_acl_delete',
    'secret_acl_get', 'secret_acl_patch', 'secret_acl_put',
)


def __virtual__():
    """Only load barbicanv1 if requirements are available."""
    if REQUIREMENTS_MET:
        return 'barbicanv1'
    else:
        return False, ("The barbicanv1 execution module cannot be loaded: "
                       "os_client_config or keystoneauth are unavailable.")
