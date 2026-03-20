'use strict';
exports.handler = async (event) => {
    // Get request and request headers
    const request = event.Records[0].cf.request;
    const headers = request.headers;
    // Configure authentication
    const authUser = '${auth_user}';
    const authPass = '${auth_password}';
    // Construct the Basic Auth string
    const authString = 'Basic ' + Buffer.from(authUser + ':' + authPass).toString('base64');
    // Require Basic authentication
    if (typeof headers.authorization == 'undefined' || headers.authorization[0].value != authString) {
        const body = 'Unauthorized';
        const response = {
            status: '401',
            statusDescription: 'Unauthorized',
            body: body,
            headers: {
                'www-authenticate': [{key: 'WWW-Authenticate', value:'Basic'}]
            },
        };
        return response;
    }

    // Continue request processing if authentication passed
    return request;
};
