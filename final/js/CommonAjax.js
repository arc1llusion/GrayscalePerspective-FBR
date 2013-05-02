/*

What this file is: An Ajax runtime library to reduce ajax code.

Functions:

getXMLHTTPRequest
- This function returns an xmlrequest object if it is native to the accounted for browsers
- If no object can be created, it returns false to signify that this cannot be executed.

AjaxNotifier
- This function will display an animated gif to say that ajax is processing depending on the arguements passed in.
- is isOn is true, it will display the notifier in the given arguement for the element. If the element doesn't exist
  it will display as such
- if isOn is false, it will empty the given element container

sendRequest
- this function takes in a whopping 6 parameters
	First is the xmlHTTPRequest object (Usually found by the aforementioned method)
	Second is the element modified for the ajax notifier
	Third is the url of the server side script to use
	Fourth is the method to send the ajax request, GET or POST, otherwise no request will be made
	Fifth is the callback function to be called once the process has finished
	Sixth is an optional datamember that gives additional parameters to the serverside script
- With all these in hand, it will differentiate between get and post, send errors if some of the arguements are not provided
  and will send your ajax request
	
serverStatus
- this function is the function that returns true when the server has finished its response, and false otherwise
- it also handles the ajax notifier, which requires the element arguement

getResponse
- this function is called everytime the server state changes in its process
- which in turn calls the server status function, which returns true when it is done processing
- and finally calls the callback function supplied in the send request method

*/

function getXMLHTTPRequest()
{
	/* This function returns an XMLHTTPRequest object regardless of its browser, or version */
	var request = false;
	try {
    request = new XMLHttpRequest(); /* e.g. Firefox */
	}
	catch(err1) {
		try
		{
			request = new ActiveXObject("Msxml2.XMLHTTP");
			/* some versions IE */
		}
		catch(err2)
		{
			try
			{
				request = new ActiveXObject("Microsoft.XMLHTTP");
				/* some versions IE */
			}
			catch(err3)
			{
				request = false;
			}
		}
	}
	return request;
}

function AjaxNotifier(isOn, element) {
	/*This function displays an image in response to an synchronous request by Ajax */
	/* It accepts a boolean, to note whether or not to display it. and the element to display it to. */
	if(isOn) {
		if(element != null)
			element.innerHTML = '<img src="ajax-loader.gif">';
		else
			alert("Element does not exist");
	}
	else {
		if(element != null)
			element.innerHTML = '';
		else
			alert("Element does not exist");
	}
}

/* This function sends data via xmlhttprequest object */ 
function sendRequest(request, element, url, method, callback, data) {
	if((typeof request != "undefined" && request != null) 
	&& typeof element != "undefined" 
	&& typeof url != "undefined" 
	&& typeof method != "undefined"
	&& typeof callback != "undefined") {
		var myRand = parseInt(Math.random()*999999999999999);
		var parameters = "?rand=myRand";
		if(typeof data != "undefined")
			parameters += "&" + data;
		
		request.onreadystatechange = function () { 
                                    getResponse(element, callback);
                                    };
		
		if(method == "GET") {
			request.open(method, url+parameters, true);
			request.send(null);
		}
		else if(method == "POST") {
			request.open(method, url, true);
			request.setRequestHeader("Content-type", "application/x-www-form-urlencoded");
			request.setRequestHeader("Content-length", parameters.length);
			request.setRequestHeader("Connection", "close");
			request.send(parameters);
		}
		else {
			alert("Not a proper method of sending information");
		}
	}
	else {
		alert("You need to pass in all arguements");
	}
}

function serverStatus(element) {
	if(request.readyState == 4) {
		AjaxNotifier(false, element);
		if(request.status == 200)
			return true;
		else
			alert("An error occurred: " + request.statusText);
	}
	else  {
		AjaxNotifier(true, element);
		return false;
	}
}

function getResponse(element, callback) {
	/* Because objects are passed by reference, the request objects properties can now be utilized, so the callback function
		is essentially saying you can now use the servers response */
	if(serverStatus(element) ) {
		callback();
	}
}