//
// Created by Spritzer App on 2018-11-01.
//

import UIKit

public class Velocity {



    public enum RequestType : String{
        case Text
        case Download
        case Upload

        func value() -> String{
            return self.rawValue
        }
    }

    public enum ContentType : String{
    //case FORM_DATA_MULTIPART = "multipart/form-data; boundary=" + BOUNDARY
        case FORM_DATA_URLENCODED = "application/x-www-form-urlencoded"
        case JSON = "application/json"
        case TEXT_PLAIN = "application/text/plain"
        case XML = "application/xml"
        case TEXT_XML = "text/xml"
        case JAVASCRIPT = "application/javascript"
        case HTML = "application/html"
        case TEXT = ""
    }

    public class Response {

        public var body: String = ""
        //public final Map<String, List<String>> responseHeaders;
        public var image: UIImage?
        public var userData: Any?
        public var responseCode = 0
        public var requestId = 0
        public var requestUrl = ""
        public var fullUrl = ""
        private let builder: RequestBuilder

        public let requestHeaders: Dictionary<String, String>
        public let formData: Dictionary<String, String>
        public var requestBody: String?
        public var requestMethod: String

        public init(requestId: Int, body: String, status: Int, image: UIImage?, userData: Any?, builder: RequestBuilder) {
            self.requestId = requestId
            self.body = body
            self.responseCode = status
            self.image = image
            self.userData = userData
            self.builder = builder

            self.fullUrl = builder.url
            self.formData = builder.params
            self.requestBody = builder.rawParams
            self.requestMethod = builder.requestMethod
        }

    }

    class Settings {

        internal static var TIMEOUT = 15000
        internal static var READ_TIMEOUT = 30000
        internal static var MOCK_RESPONSE_TIME = 1000
        internal static var GLOBAL_MOCK = false
        internal static var GLOBAL_NETWORK_DELAY = 0
        internal static var MAX_REDIRECTS = 10
        internal static var LOGS_ENABLED = false
        internal static var USER_AGENT = "velocity-android-http-client"
        internal static var GZIP_ENABLED = false
        //upload settings
        internal static let LINEEND = "\r\n"
        internal static let TWOHYPHENS = "--"
        internal static var BOUNDARY = "--VelocityFormBoundary--"
        internal static var MAX_BUFFER = 4096

        /**
       * Sets a specified timeout value, in milliseconds, to be used when opening a connection to the specified URL.
       * A timeout of zero is interpreted as an infinite timeout.
       *
       * @param timeout connection timeout in milliseconds
       */
        func setTimeout(timeout: Int) {
            NetLog.d("set connection timeout: \(timeout)")
            Velocity.Settings.TIMEOUT = timeout
        }

        /**
       * Sets the read timeout to a specified timeout, in milliseconds. A non-zero value specifies the timeout when
       * reading from Input stream once a connection is established to a resource.
       * A timeout of zero is interpreted as an infinite timeout.
       *
       * @param readTimeout read timeout in milliseconds
       */
        func setReadTimeout(readTimeout: Int) {
            NetLog.d("set read timeout: \(readTimeout)")
            Velocity.Settings.READ_TIMEOUT = readTimeout
        }

        /**
        * Set the boundary String for multi-part uploads.
        * The default is "*****"
        *
        * @param boundary multi-part upload boundary string
        */
        func setMultipartBoundary(boundary: String) {
            NetLog.d("set multipart boundary: \(boundary)")
            Velocity.Settings.BOUNDARY = boundary
        }

        /**
        * Set the buffer size for multi-part uploads
        * Default size is 1024KB
        *
        * @param bufferSize upload buffer size
        */
        func setMaxTransferBufferSize(bufferSize: Int) {
            NetLog.d("set max transfer buffer size: \(bufferSize)")
            Velocity.Settings.MAX_BUFFER = bufferSize
        }

        /**
        * Set the global response time for mocked api calls
        *
        * @param waitTime response time
        */
        func setMockResponseTime(waitTime: Int) {
            NetLog.d("Set mock response delay to: \(waitTime)")
            Velocity.Settings.MOCK_RESPONSE_TIME = waitTime
        }

        /**
        * Set all calls mocked
        *
        * @param mocked if true, all subsequent calls will be mocked
        */
        func setGloballyMocked(mocked: Bool) {
            NetLog.d("set global mock : \(mocked)")
            Velocity.Settings.GLOBAL_MOCK = mocked
        }

        /**
        * Set the global network simulation delay
        *
        * @param delay delay in milliseconds
        */
        func setGlobalNetworkDelay(delay: Int) {
            NetLog.d("set global network delay: \(delay)")
            Velocity.Settings.GLOBAL_NETWORK_DELAY = delay
        }

        /**
        * Sets the maximum number of redirects poer request
        *
        * @param redirects number of redirects
        */
        func setMaxRedirects(redirects: Int) {
            NetLog.d("Set max redirects: \(redirects)")
            Velocity.Settings.MAX_REDIRECTS = redirects
        }

        /**
        * Enable or disable logginf. Disabled by default.
        *
        * @param enabled enabled state
        */
        func setLoggingEnabled(enabled: Bool) {
            print("Velocity", "Log enabled: \(enabled)")
            Velocity.Settings.LOGS_ENABLED = enabled
        }

        /**
        * Sets a custom user agent string
        *
        * @param userAgent user agent to set. (set 'nil' to reset to default)
        */
        func setUserAgent(userAgent: String) {
            if userAgent != nil {

                print("Velocity", "Set user agent: \(userAgent)")
                Velocity.Settings.USER_AGENT = userAgent
            }
        }

        /**
        * Set redirect handling to system or velocity
        * This is left for the system by default. However, if the system doesnt handle a 302 or 303
        * automatically then Velocity will handle this regardless of the value set for 'follow'
        *
        * @param follow if true - the android system will handle redirects, if false - velocity will handle them
        */
//        func setAutoRedirects(follow: Bool) {
//            HttpURLConnection.setFollowRedirects(follow)
//        }

        /**
        * Set a custom logger class that inherits from {@link Logger}
        *
        * @param logger custom log class
        */
//        func setCustomLogger(logger: Logger) {
//            NetLog.setLogger(logger)
//        }

        /**
        * Enable gzip compression
        * Adds 'Accept-Encoding = gzip,deflate' header to all requests
        * @param enabled if true, enabled compression
        */
        func setResponseCompressionEnabled(enabled: Bool) {
            Velocity.Settings.GZIP_ENABLED = enabled
        }

    }
}

public protocol ResponseListener {
    func onVelocitySuccess(response: Velocity.Response)
    func onVelocityFailed(error: Velocity.Response)
}

public protocol MultiResponseListener {
    func onVelocityMultiResponseSuccess(responseMap: Dictionary<Int, Velocity.Response>)
    func onVelocityMultiResponseError(errorMap: Dictionary<Int, Velocity.Response>)
}

public protocol ProgressListener {
    func onFileProgress(percentage: Int);
}






