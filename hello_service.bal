import ballerina/http;
import ballerina/io;

endpoint http:Listener listener {
    port: 9099
};

map<json> notificationservice;

@http:ServiceConfig {
    basePath: "/"
}

service<http:Service> hello bind listener {

    @http:ResourceConfig {
        methods: ["POST"],
        path: "/notification"
    }

    getsubscriptionNotification(endpoint client, http:Request req) {
        http:Response response;
        //xml payload = check req.getXmlPayload();
        var payload = req.getXmlPayload();

        //Read XML file
        match payload {
            xml result => {
                json j1 = result.toJSON({});
                string x = j1.toString();
                string[] array = x.split(" ");

                int i = 0;
                string output = "";

                while (i < lengthof array) {
                    //io:println("  " + array[i]);
                    output += array[i] + "  \n  ";
                    i = i + 1;
                }

                response.setTextPayload(untaint output);
                _ = client->respond(response);
                //io:println(output);              
                //io:println(j1);
            }
            error err => {
                response.statusCode = 404;
                json payload1 = " XML file cannot read ";
                response.setJsonPayload(payload1);
                _ = client->respond(response);
            }

        }

    }


    @http:ResourceConfig {
        methods: ["POST"],
        path: "/notificationwritetofile"
    }

    getsubscriptionandwriteNotification(endpoint client, http:Request req) {
        http:Response response;
        //xml payload = check req.getXmlPayload();
        var payload = req.getXmlPayload();

        //Read XML file
        match payload {
            xml result => {
                json j1 = result.toJSON({});
                string x = j1.toString();

                string[] array = x.split(" ");

                int i = 0;

                string output = "";

                while (i < lengthof array) {
                    //io:println("  " + array[i]);
                    output += array[i] + "  \n  ";
                    i = i + 1;
                }

                string filePath = "./files/test.txt";
                //Create the byte channel for file path
                io:ByteChannel byteChannel = io:openFile(filePath, io:WRITE);
                //Derive the character channel for the above byte channel
                io:CharacterChannel ch = new io:CharacterChannel(byteChannel, "UTF8");

                match ch.writeJson(output) {
                    error err => {
                        response.statusCode = 400;
                        json payload1 = " Error occurred writing character stream ";
                        response.setJsonPayload(payload1);
                        _ = client->respond(response);

                    }
                    () => {
                        response.setTextPayload("Content written Sucessfully:" + untaint output);
                        _ = client->respond(response);
                    } }

            }
            error err => {
                response.statusCode = 404;
                json payload1 = " XML file cannot read ";
                response.setJsonPayload(payload1);
                _ = client->respond(response);
            }

        }


    }

}
