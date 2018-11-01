//
// Created by Spritzer App on 2018-11-01.
//

import Foundation

public class Request {
    var mBuilder: RequestBuilder
    var mRequest: URLRequest?
    //var mResponse = StringBuilder()
    //private var mResponseImage: Bitmap = nil
    var mResponseCode = 0
    private var formattedParams: String

    init(_ builder: RequestBuilder) {
        self.mBuilder = builder
    }

    /**
    * DO NOT CALL THIS DIRECTLY
    * Execute the network requet and post the response.
    * This function will be called from a worker thread from within the Threadpool
    */
    func execute() {
        let t = NSDate().timeIntervalSince1970

        if (mBuilder.mocked || Velocity.Settings.GLOBAL_MOCK) {
            usleep(UInt32(1000 * Velocity.Settings.MOCK_RESPONSE_TIME))
            let elapsed = NSDate().timeIntervalSince1970 - t

            NetLog.d("MOCKED/\(mBuilder.requestMethod) : \(elapsed)ms : \(mBuilder.url)")
            returnMockResponse()

        } else {
//            var success = initializeConnection()
//            if success {
//                success = readResponse()
//                if !success {
//                    readError()
//                }
//            }
            makeConnection()
            let status = readResponse()

            let elapsed = NSDate().timeIntervalSince1970 - t
            NetLog.d("\(mResponseCode)/\(mBuilder.requestMethod) : \(elapsed)ms : \(mBuilder.url)")
            returnResponse(status)
        }
    }


//    private func initializeConnection() -> Bool {
//        var ret: Bool
//        do{
//            mResponseCode = try makeConnection()
//            var count = 0
//            while ((mResponseCode == HttpURLConnection.HTTP_MOVED_PERM || mResponseCode == HttpURLConnection.HTTP_MOVED_TEMP) && count < Velocity.Settings.MAX_REDIRECTS) {
//                count++
//                var u = URL(mBuilder.url)
//                var location = mConnection.getHeaderField("Location")
//                if (location.startsWith("/"))
//                //relative redirect
//                mBuilder.url = u.getProtocol() + "://" + u.getHost() + location
//        else
//        mBuilder.url = location
//        NetLog.d(mResponseCode + "/redirected : " + mBuilder.url)
//        mResponseCode = makeConnection()
//        }
//        ret = true
//        }
//        catch (ioe: IOException) {
//        ret = false
//        mResponse = StringBuilder(ioe.toString())
//        }
//        return ret
//    }


    func setupRequestHeaders() {

        mRequest?.addValue(Velocity.Settings.USER_AGENT, forHTTPHeaderField: "User-Agent")


        if mBuilder.contentType != nil && !(mBuilder.contentType ?? "" != Velocity.ContentType.TEXT.rawValue) {
            mRequest?.addValue(mBuilder.contentType ?? "", forHTTPHeaderField: "Content-Type")
        }

        if Velocity.Settings.GZIP_ENABLED {
            mRequest?.addValue("gzip,deflate", forHTTPHeaderField: "Accept-Encoding")
        }

        if !mBuilder.headers.isEmpty {

            for (k, v) in mBuilder.headers {
                mRequest?.addValue(v, forHTTPHeaderField: k)
            }
        }
    }

    func setupRequestBody() {

        mRequest?.httpBody

        if mBuilder.requestMethod == "GET" || mBuilder.requestMethod == "COPY" || mBuilder.requestMethod == "HEAD"
                || mBuilder.requestMethod == "PURGE" || mBuilder.requestMethod == "UNLOCK" {
            //do not send params for these request methods
            return
        }

        if !mBuilder.params.isEmpty {
            mRequest?.httpBody = Data(bytes: mBuilder.params.)
        }
        if (mBuilder.rawParams != nil) {
            if (mBuilder.contentType != nil && mBuilder.contentType.equalsIgnoreCase(Velocity.ContentType.FORM_DATA_MULTIPART.toString())) {
                var dos = DataOutputStream(mConnection.getOutputStream())
                for (param in mBuilder.params.keySet())
                {
                    var `val` = mBuilder.params.get(param)
                    dos.writeBytes(Velocity.Settings.TWOHYPHENS + Velocity.Settings.BOUNDARY + Velocity.Settings.LINEEND)
                    dos.writeBytes("Content-Disposition: form-data; name=\"" + param + "\"" + Velocity.Settings.LINEEND)
                    dos.writeBytes("Content-Type: text/plain" + Velocity.Settings.LINEEND)
                    dos.writeBytes(Velocity.Settings.LINEEND)
                    dos.writeBytes(`val`)
                    dos.writeBytes(Velocity.Settings.LINEEND)
                }
                dos.writeBytes(Velocity.Settings.TWOHYPHENS + Velocity.Settings.BOUNDARY + Velocity.Settings.TWOHYPHENS + Velocity.Settings.LINEEND)
                dos.flush()
                dos.close()
            } else {
                var os = mConnection.getOutputStream()
                var writer = BufferedWriter(OutputStreamWriter(os, "UTF-8"))
                writer.write(mBuilder.rawParams)
                writer.flush()
                writer.close()
                os.close()
            }
        }
    }


    private func makeConnection() {


        var url = URL(url: mBuilder.url)
        mRequest = URLRequest(url: url)

        mRequest?.httpMethod = mBuilder.requestMethod
        mRequest?.timeoutInterval = TimeInterval(exactly: Velocity.Settings.TIMEOUT / 1000.0)

        setupRequestHeaders()
        setupRequestBody()


    }

    func readResponse()

:Bool {
    var ret: Bool
try
{

if (mResponseCode / 100 == 2)
//all 2xx codes are OK {
var `in` = mConnection.getInputStream()
if (mConnection.getHeaderField("Content-Encoding") != nil && mConnection.getHeaderField("Content-Encoding").contains("gzip")) {
    `in` = GZIPInputStream(`in`)
}
if (mConnection.getContentType() != nil && mConnection.getContentType().startsWith("image")) {
    mResponseImage = BitmapFactory.decodeStream(`in`)
    mResponse.append(mConnection.getContentType())
} else {
    var inStream = BufferedInputStream(`in`)
    var reader = BufferedReader(InputStreamReader(inStream))
    var line: String
    while ((line = reader.readLine()) != nil) {
        mResponse.append(line)
    }
}
ret = true
} else
ret = false
}
catch (e: IOException) {
    ret = false
    mResponse = StringBuilder(e.toString())
}
return ret
}

private func readError() {
    var `in` = BufferedInputStream(mConnection.getErrorStream())
    var reader = BufferedReader(InputStreamReader(`in`))
    try
    {
        var line: String
        while ((line = reader.readLine()) != nil) {
            mResponse.append(line)
        }
    }
    catch (e: IOException) {
        mResponse.append(e.toString())
    }
}

private func returnMockResponse() {
    var reply = Velocity.Response(mBuilder.requestId,
            mBuilder.mockResponse,
            200, nil, nil,
            mBuilder.userData,
            mBuilder)
    var r = object:Runnable {
        public override func run() {
            if (mBuilder.callback != nil) {
                mBuilder.callback.onVelocitySuccess(reply)
            } else
            NetLog.d("Warning: No Data callback supplied")
        }
    }
    ThreadPool.getThreadPool().postToUiThread(r)
}

private func returnResponse(_ success: Bool) {
    var reply = Velocity.Response(mBuilder.requestId,
            mResponse.toString(),
            mResponseCode,
    if ((mConnection == nil)) nil else mConnection.getHeaderFields(),
    mResponseImage,
    mBuilder.userData,
    mBuilder)
    var r = object:Runnable {
    public override func run() {
    if (mBuilder.callback != nil)
    {
    if (success)
    mBuilder.callback.onVelocitySuccess(reply)
    else
    {
    NetLog.conError(reply, nil)
    mBuilder.callback.onVelocityFailed(reply)
    }
    }
    else
    NetLog.d("Warning: No Data callback supplied")
    }
    }
    }