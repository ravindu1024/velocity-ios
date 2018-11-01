//
// Created by Spritzer App on 2018-11-01.
//

import Foundation

public class RequestBuilder {
    var headers = Dictionary<String, String>()
    var params = Dictionary<String, String>()
    var queryParams = Array<Pair<String, String>>()
    var rawParams: String?
    var requestMethod = "GET"
    var userData: Any? = nil
    var uploadFile: String?
    var uploadParamName: String?
    var uploadMimeType: String?
    var uploadStream: Any?
    //String                downloadFile;
    //Velocity.DownloadType downloadType;
    //String downloadUiTitle = "";
    //String downloadUiDescr = "";
    var requestId = -1
    var contentType: String?
    var callback: ResponseListener
    var url: String
    let originUrl: String
    var progressListener: ProgressListener
    var mocked = false
    var compressed = false
    var mockResponse = "Global Mock is enabled. Velovity will mock all calls and return self message.";

    private var requestType = Velocity.RequestType.Text;

    private init() {
        //will not be called from outside
        //self.url = nil;
        //self.originUrl = nil;
    }

    public init(url: String, type: Velocity.RequestType) {
        self.url = url;
        self.originUrl = url;
        self.requestType = type;
    }

    /**
     * Add HTTP request headers as a Dictionary<String, String>
     *
     * @param headers request headers
     * @return request builder
     */
    public func withHeaders(headers: Dictionary<String, String>) -> RequestBuilder {

        headers.forEach { (key, value) in self.headers[key] = value }
        return self;
    }

    /**
     * Add a single request header
     *
     * @param key   request header key
     * @param value request header value
     * @return request builder
     */
    public func withHeader(key: String, value: String) -> RequestBuilder {
        self.headers[key] = value
        return self;
    }

    /**
     * Add a single path encoded parameter
     *
     * @param key   path parameter key
     * @param value path parameter value
     * @return request builder
     */
    public func withQueryParam(key: String, value: String) -> RequestBuilder {
        self.queryParams.append(Pair(key, value))
        return self;
    }


    /**
     * Add a list of path parameters
     *
     * @param queryParams map containing path parameters and key values
     * @return request builder
     */
    public func withQueryParams(queryParams: Dictionary<String, String>) -> RequestBuilder {
        queryParams.forEach{(key, value) in self.queryParams.append(Pair(key, value))}
        return self;
    }

    /**
     * Add HTTP form data as a Dictionary<String, String>. Content type: application/x-www-form-urlencoded-data
     *
     * @param params form data
     * @return request builder
     */
    public func withBody(params: Dictionary<String, String>) -> RequestBuilder {
        params.forEach{(k, v) in self.params[k] = v}
        self.contentType = Velocity.ContentType.FORM_DATA_URLENCODED.rawValue;
        return self;
    }

    /**
     * Add HTTP params as a String (raw JSON string). "Content type" will not be set in request headers.
     *
     * @param params raw parameter String
     * @return request builder
     */
    public func withBody(params: String) -> RequestBuilder {
        self.rawParams = params;
        self.contentType = Velocity.ContentType.TEXT.rawValue;
        return self;
    }

    /**
     * Add HTTP body as a json object. Content type: application/json
     *
     * @param toJsonObect body
     * @return self builder
     */
    public func withJsonBody<T: Encodable>(toJsonObect: T) -> RequestBuilder {

        let data = try! JSONEncoder().encode(toJsonObect)
        self.rawParams = String(data: data, encoding: .utf8)
        self.contentType = Velocity.ContentType.JSON.rawValue;

        return self;
    }

    /**
     * Add HTTP params as a String and set the content type. self is added as a request header specifying
     * the parameter type for the call
     *
     * @param params    raw parameter String
     * @param paramType from {@link Velocity.ContentType}
     * @return request builder
     */
    public func withBody(params: String, paramType: Velocity.ContentType) -> RequestBuilder {
        self.rawParams = params;
        self.contentType = paramType.rawValue
        return self;
    }


    /**
     * Add a key value pair as encoded form data. Content type: application/form-x-www-form-urlencoded
     *
     * @param key   parameter key
     * @param value parameter value
     * @return request builder
     */
    public func withFormData(key: String, value: String) -> RequestBuilder {
        self.params[key] = value
        self.contentType = Velocity.ContentType.FORM_DATA_URLENCODED.rawValue;
        return self;
    }

    /**
     * Set HTTP body content type
     *
     * @param contentType select from {@link Velocity.ContentType}
     * @return self builder
     */
    public func withBodyContentType(contentType: Velocity.ContentType) -> RequestBuilder {
        self.contentType = contentType.rawValue;
        return self;
    }


    public func withRequestMethod(method: String) -> RequestBuilder {
        self.requestMethod = method;
        return self;
    }

    /**
     * Set any object to self field to get it returned through the data callback
     *
     * @param data user data
     * @return request builder
     */
    public func withData(data: Any?) -> RequestBuilder {
        self.userData = data;
        return self;
    }

    /**
     * Set self request as a mock request that will return the given response
     *
     * @param mockResponse the response to be returned
     * @return request builder
     */
    public func setMocked(mockResponse: String) -> RequestBuilder {
        self.mocked = true;
        self.mockResponse = mockResponse;
        return self;
    }

/**
 * Set the download location and filename
 *
 * @param downloadFile the name of the file to be saved
 * @return self builder
 */
//public func setDownloadFile(downloadFile: String) -> RequestBuilder
//{
//    self.downloadFile = downloadFile;
//    return self;
//}

/**
 * Set the download file type
 * 'Automatic' : set the type from the response headers
 * 'Base64toPdf' : convert the base64 response into a pdf file and save
 * 'Base64toJpg' : convert the base64 response into a jpeg and save
 *
 * @param type download file type
 * @return self builder
 */
//public RequestBuilder setDownloadFileType(Velocity.DownloadType type)
//{
//    self.downloadType = type;
//    return self;
//}

/**
 * set the details of the file to be uploaded
 *
 * @param paramName  form parameter name(or field) corresponding to self file (eg: "profile-picture" or "id-scan" etc)
 * @param mimeType   mime type of the file. eg: "text/plain" , "image/jpeg" or "video/mp4"
 * @param uploadFile path to the file to be uploaded
 * @return RequestBuilder
 */
    public func setUploadSource(paramName: String, mimeType: String, uploadFile: String) -> RequestBuilder {
        self.uploadMimeType = mimeType;
        self.uploadFile = uploadFile;
        self.uploadParamName = paramName;
        return self;
    }

/**
 * @param uploadStream an open file as an {@link InputStream}
 * @see RequestBuilder#setUploadSource(String, String, String)
 */
    public func setUploadSource(paramName: String, mimeType: String, uploadStream: Any) -> RequestBuilder {
        self.uploadMimeType = mimeType;
        self.uploadParamName = paramName;
        self.uploadStream = uploadStream;
        return self;
    }

/**
 * @param stream an opened data stream
 * @return RequestBuilder
 * @see RequestBuilder#setUploadSource(String, String, String)
 */
    public func setUploadSource(stream: Any) -> RequestBuilder {
        self.uploadMimeType = "application/octet-stream";
        self.uploadStream = stream;

        return self;
    }

/**
 * Add downloaded file to the system Downloads Ui
 *
 * @param context     calling context
 * @param title       title to be displayed in Downloads
 * @param description description of the downloaded file to be displayed in Downloads
 * @return RequestBuilder
 */
//public func addToDownloadsFolder(Context context, String title, String description: String) -> RequestBuilder
//{
//    self.context = context;
//    self.downloadUiTitle = title;
//    self.downloadUiDescr = description;
//
//    return self;
//}


/**
 * Receive progress notifications on a file download or upload.
 * self parameter will be ignored for text or image requests
 *
 * @param listener file progress listener
 * @return request builder
 */
    public func withProgressListener(listener: ProgressListener) -> RequestBuilder {
        self.progressListener = listener;
        return self;
    }

    public func withResponseCompression() -> RequestBuilder {
        self.compressed = true;
        return self;
    }

/**
 * Make a network request to recieve data in the callback.
 * See also {@link RequestBuilder#connect(int, Velocity.ResponseListener)}
 *
 * @param callback data callback
 */
    public func connect(callback: ResponseListener) {
        self.callback = callback;
        self.url += getQueryParams();

        DispatchQueue.global(priority: .high).async{
            //do request and
            let request = self.resolveRequest()
            request.execute()

        }

        //ThreadPool.getThreadPool().postRequestDelayed(resolveRequest(), Velocity.Settings.GLOBAL_NETWORK_DELAY);
    }

/**
 * Make a network request to recieve data in the callback. The request id is returned so that
 * the same callback can be used for multiple calls.
 *
 * @param requestId unique request id
 * @param callback  data callback
 */
    public func connect(requestId: Int, callback: ResponseListener) {
        self.requestId = requestId;
        self.callback = callback;
        self.url += getQueryParams();

        //ThreadPool.getThreadPool().postRequestDelayed(resolveRequest(), Velocity.Settings.GLOBAL_NETWORK_DELAY);
    }


/**
 * Add the calling RequestBuilder to the request queue
 *
 * @param requestId identifier of the request
 */
    public func queue(requestId: Int) {
        self.requestId = requestId;

        //MultiResponseHandler.addToQueue(self);
    }


//    public func connectBlocking() -> Velocity.Response {
//        if (Looper.myLooper() == Looper.getMainLooper())
//        throw new NetworkOnMainThreadException();
//
//        return new SynchronousWrapper().connect(self);
//    }


    private func getQueryParams() -> String {
        var path = "";

        if (!queryParams.isEmpty()) {
            for p in queryParams {
                path += "&" + p.first + "=" + p.second;
            }
        }


        if path.starts(with: "&") {
            let index = path.index(path.startIndex, offsetBy: 1)
            path = "?" + path.substring(from: index)
        }

        return path;
    }


    private func resolveRequest() -> Request {

        //if requestType == Velocity.RequestType.Download {
        //    return DownloadRequest(self)
        if requestType == Velocity.RequestType.Upload {
            return UploadRequest(self)
        } else {
            return Request(self)
        }


    }
}