import logging
import tempfile
import shutil
import os

try:
    from urllib.parse import urlsplit
except ImportError:
    from urlparse import urlsplit

GLANCE_LOADED = False
CMD_LOADED = False


def __virtual__():
    if 'glancev2.image_list' in __salt__:
        global GLANCE_LOADED
        GLANCE_LOADED = True
    if 'cmd.run_all' in __salt__:
        global CMD_LOADED
        CMD_LOADED = True
    return 'barbicanv1' if 'barbicanv1.secret_list' in __salt__ else False


log = logging.getLogger(__name__)


def _barbicanv1_call(fname, *args, **kwargs):
    return __salt__['barbicanv1.{}'.format(fname)](*args, **kwargs)


def _glancev2_call(fname, *args, **kwargs):
    return __salt__['glancev2.{}'.format(fname)](*args, **kwargs)


def _cmd_call(fname, *args, **kwargs):
    return __salt__['cmd.{}'.format(fname)](*args, **kwargs)


def secret_present(name, cloud_name, **kwargs):
    try:
        exact_secret = _barbicanv1_call(
            'secret_get_details', name=name, cloud_name=cloud_name
        )
    except Exception as e:
        if 'ResourceNotFound' in repr(e):
            try:
                if not kwargs:
                    kwargs = {}
                resp = _barbicanv1_call(
                    'secret_create', name=name, cloud_name=cloud_name, **kwargs
                )
            except Exception as e:
                log.error('Barbicanv1 create secret failed with {}'.format(e))
                return _create_failed(name, 'secret')
            return _created(name, 'secret', resp)
        if 'MultipleResourcesFound' in repr(e):
            return _find_failed(name, 'secret')
    if 'payload' in kwargs:
        try:
            _barbicanv1_call(
                'secret_payload_get', name=name, cloud_name=cloud_name
            )
        except Exception:
            try:
                _barbicanv1_call(
                    'secret_payload_set', name=name, payload=kwargs['payload'],
                    cloud_name=cloud_name, **kwargs
                )
            except Exception as e:
                log.error(
                    'Barbicanv1 Secret set payload failed with {}'.format(e)
                )
                return _update_failed(name, 'secret_payload')
            return _updated(
                name, 'secret_payload', {'payload': kwargs['payload']}
            )
    return _no_changes(name, 'secret')


def secret_absent(name, cloud_name, **kwargs):
    try:
        secret = _barbicanv1_call(
            'secret_get_details', name=name, cloud_name=cloud_name
        )
    except Exception as e:
        if 'ResourceNotFound' in repr(e):
            return _absent(name, 'secret')
        if 'MultipleResourcesFound' in repr(e):
            return _find_failed(name, 'secret')
    try:
        _barbicanv1_call('secret_delete', name=name, cloud_name=cloud_name)
    except Exception as e:
        log.error('Barbicanv1 delete failed with {}'.format(e))
        return _delete_failed(name, 'secret')
    return _deleted(name, 'secret')


def glance_image_signed(image_name, secret_name, pk_fname, out_fname,
                        cloud_name, file_name=None, force_resign=False):
    """

    :param image_name: The name of the image to sign
    :param secret_name: Secret's name with certificate
    :param pk_fname: private_key file name
    :param out_fname: output filename for signature
    :param cloud_name: name of the cloud in cloud_yaml
    :param file_name: name of the file where downloaded image is.
    :param force_resign: if the image is already signed, resign it.
    """
    if not GLANCE_LOADED or not CMD_LOADED:
        return {
            'name': image_name,
            'changes': {},
            'comment': 'Cant sign an image, glancev2 and/or cmd module '
                       'are/is absent',
            'result': False,
        }
    try:
        image = _glancev2_call(
            'image_get_details', name=image_name, cloud_name=cloud_name
        )
    except Exception as e:
        log.error('Barbicanv1 sign_image find image failed with {}'.format(e))
        return _create_failed(image_name, 'image')

    sign_properties = (
        'img_signature', 'img_signature_certificate_uuid',
        'img_signature_hash_method', 'img_signature_key_type',
    )

    if not force_resign and all(key in image for key in sign_properties):
        return _no_changes(image_name, 'image_signature')

    file_name = file_name or image['id']
    dir_path = tempfile.mkdtemp()
    try:
        file_path = os.path.join(dir_path, file_name)

        _glancev2_call(
            'image_download', name=image_name,
            file_name=file_path,
            cloud_name=cloud_name
        )
    except Exception as e:
        log.error(
            "Barbicanv1 sign image can't download image."
            " failed with {}".format(e)
        )
        return _create_failed(image_name, 'downloading_image')

    try:
        retcode = _cmd_call(
            'run_all',
            'openssl dgst -sha256 -sign {} '.format(pk_fname) +
            '-sigopt rsa_padding_mode:pss -out {} '.format(out_fname) +
            file_path
          )['retcode']
        if not retcode == 0:
            raise Exception('Cant sign image')
        image_signature = _cmd_call(
            'run_all', 'base64 -w  0 {}'.format(out_fname)
        )['stdout']
    except Exception as e:
        log.error(
            'Barbicanv1 sign image failed because of cmd with {}'.format(e)
        )
        return _create_failed(image_name, 'cmd_module')
    shutil.rmtree(dir_path)

    secret_ref = _barbicanv1_call(
        'secret_get_details', name=secret_name, cloud_name=cloud_name
    )['secret_ref']

    def _parse_secret_href(href):
        return urlsplit(href).path.split('/')[-1]

    secret_uuid = _parse_secret_href(secret_ref)

    to_update = [
        {
            'op': 'add',
            'path': '/img_signature',
            'value': image_signature,
        },
        {
            'op': 'add',
            'path': '/img_signature_certificate_uuid',
            'value': secret_uuid,
        },
        {
            'op': 'add',
            'path': '/img_signature_hash_method',
            'value': 'SHA-256',
        },
        {
            'op': 'add',
            'path': '/img_signature_key_type',
            'value': 'RSA-PSS'
        }

    ]
    try:
        resp = _glancev2_call(
            'image_update', image_name, to_update, cloud_name=cloud_name,
            headers={
                "Content-Type": "application/openstack-images-v2.1-json-patch"
            }
        )
    except Exception as e:
        log.error('Barbicanv1 sign image failed with {}'.format(e))
        return _create_failed(image_name, 'sign_image')
    return _created(image_name, 'sign_image', resp)


def _created(name, resource, resource_definition):
    changes_dict = {
        'name': name,
        'changes': resource_definition,
        'result': True,
        'comment': '{}{} created'.format(resource, name)
    }
    return changes_dict


def _updated(name, resource, resource_definition):
    changes_dict = {
        'name': name,
        'changes': resource_definition,
        'result': True,
        'comment': '{}{} updated'.format(resource, name)
    }
    return changes_dict


def _no_changes(name, resource):
    changes_dict = {
        'name': name,
        'changes': {},
        'result': True,
        'comment': '{}{} is in desired state'.format(resource, name)
    }
    return changes_dict


def _deleted(name, resource):
    changes_dict = {
        'name': name,
        'changes': {},
        'result': True,
        'comment': '{}{} removed'.format(resource, name)
    }
    return changes_dict


def _absent(name, resource):
    changes_dict = {'name': name,
                    'changes': {},
                    'comment': '{0} {1} not present'.format(resource, name),
                    'result': True}
    return changes_dict


def _delete_failed(name, resource):
    changes_dict = {'name': name,
                    'changes': {},
                    'comment': '{0} {1} failed to delete'.format(resource,
                                                                 name),
                    'result': False}
    return changes_dict


def _create_failed(name, resource):
    changes_dict = {'name': name,
                    'changes': {},
                    'comment': '{0} {1} failed to create'.format(resource,
                                                                 name),
                    'result': False}
    return changes_dict


def _update_failed(name, resource):
    changes_dict = {'name': name,
                    'changes': {},
                    'comment': '{0} {1} failed to update'.format(resource,
                                                                 name),
                    'result': False}
    return changes_dict


def _find_failed(name, resource):
    changes_dict = {
        'name': name,
        'changes': {},
        'comment': '{0} {1} found multiple {0}'.format(resource, name),
        'result': False,
    }
    return changes_dict
