import os
import werkzeug
import http

TOKEN = ''
ICON = ''
PORT = 4000


def application(environ, start_response):
    request = werkzeug.wrappers.Request(environ)

    if not all((
            request.method == 'POST',
            request.headers.get('AUTHORIZATION') == TOKEN,
            request.values,
    )):
        raise werkzeug.exceptions.ServiceUnavailable

    subject = str(request.values.get('subject', '')).strip()
    message = str(request.values.get('message', '')).strip()

    if not all((subject, message)):
        raise werkzeug.exceptions.ServiceUnavailable

    os.system(f'notify-send -i "{ICON}" "{subject}" "{message}"')
    return werkzeug.wrappers.Response(None, status=http.HTTPStatus.NO_CONTENT)(environ, start_response)


if __name__ == '__main__':
    werkzeug.serving.run_simple('0.0.0.0', PORT, application)
