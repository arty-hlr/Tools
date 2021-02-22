from base64 import b64encode

def encode_decimal(c):
    return '&#{};'.format(ord(c))

def encode_unicode(c):
    return '\\u00{}'.format(hex(ord(c))[2:])

def encode_octal(c):
    return '\\{}'.format(oct(ord(c))[2:])

def encode_hex_at(c):
    return '&#x00{};'.format(hex(ord(c))[2:])

def encode_hex_slash(c):
    return '\\x{};'.format(hex(ord(c))[2:])

def encode_url(c):
    return '%{}'.format(hex(ord(c))[2:])

def charCode(s):
    result = 'String.fromCharCode('
    for c in s:
        result += str(ord(c)) + ','
    result += ')'
    return result

def encode(s, f):
    result = ''
    for c in s:
        result += f(c)
    return result

def atob(s):
    return "atob('"+b64encode(s.encode()).decode()+"')"

def toString(s):
    return '{}..toString(36)'.format(int(s, 36))

if __name__ == '__main__':
    payload = "alert('l33t')"
    encoded = charCode(payload)
    encoded = atob(payload)
    encoded = encode(payload, encode_hex_at)

    payload = 'alert'
    encoded = toString(payload)
