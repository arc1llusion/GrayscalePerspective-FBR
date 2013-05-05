var actionUrl = "https://crux.baker.edu/~jgerma08/cgi-bin/final/actions.cgi";
var homeUrl = "https://crux.baker.edu/~jgerma08/final/";

function LogIn(showLoader, result) {
	if(showLoader && typeof(result) != 'undefined') {
		showLoadingImageInElement(result);
	}
	
	$.post(actionUrl, 
	{
		action: "login",
		username: $("#gs_username").val(),
		password: $("#gs_password").val()
	}, 
	function(data, status) {	
		var resulttext = "Invalid username and password.";
		if(data == "1") {
			resulttext = "You're logged in!";
			document.location.href = homeUrl;		
		}
			
		$(result).text(resulttext);
	});
}

function RegisterUser(showLoader, result) {

	var v_username = $("#gs_reg_username").val();
	var v_password = $("#gs_reg_password").val();
	var v_email = $("#gs_reg_email").val();
	var v_firstname = $("#gs_reg_firstname").val();
	var v_lastname = $("#gs_reg_lastname").val();
	var v_charactername = $("#gs_reg_charactername").val();
	var v_classid = $("#gs_reg_classid").val();
	
	var v_error = "";
	
	if(IsNullOrEmpty(v_username))
		v_error += "Username can't be empty <br />";
	if(IsNullOrEmpty(v_password))
		v_error += "Password can't be empty <br />";
	if(!ValidatePassword(v_password))
		v_error += "Password is invalid. It must contain at least 8 chracters, one number, one letter, and one character such as !#$%&? \" <br />";
	if(IsNullOrEmpty(v_email))
		v_error += "Email can't be empty <br />";
	if(!ValidateEmail(v_email))
		v_error += "Email is invalid. Should be in the format of somename@email.com";
	
	if(v_error != "") {
		$(result).html(v_error);
		return;
	}
	
	if(showLoader && typeof(result) != 'undefined') {
		showLoadingImageInElement(result);
	}
	
	$.post(actionUrl, 
	{
		action: "reguser",
		username: v_username,
		password: v_password,
		email: v_email,
		firstname: v_firstname,
		lastname: v_lastname,
		charactername: v_charactername,
		classid: v_classid
	}, 
	function(data, status) {
		var resulttext = "Invalid username and password.";
		if(data == "1")
			resulttext = "You've registered! Try logging in!";			
			
		$(result).text(resulttext);
	});
}

function LogOut() {
	$.post(actionUrl, 
	{
		action: "logout"
	}, function(data, status) {		
		document.location.href = homeUrl;
	});
}

function GetDecksForLoggedInUser(result) {
	GetHTMLTemplate( {action: "decklisting"}, result, true);
}

function CreateDeck (showLoader, result) {
	if(showLoader && typeof(result) != 'undefined') {
		showLoadingImageInElement(result);
	}
	
	$.post(actionUrl, 
	{
		action: "createdeck",
		title: $("#gs_deckname").val(),
		category: $("#gs_category").val()
	}, function(data, status) {		
		$(result).html(data);
	});
}

function GetHTMLTemplate(data, output, showLoader, callback) {
	if(showLoader && typeof(output) != 'undefined') {
		showLoadingImageInElement(output);
	}
	
	$.post(actionUrl, 
	data, 
	function(data, status) {		
		$(output).html(data);
		
		if(typeof(callback) == 'function') {
			callback();
		}
	});
}

function Challenge() {
	var v_challengeCharacter = $("#gs_character_challenge").val();
	
	$.post(actionUrl, 
	{
		action: "challenge",
		charchallenge: v_challengeCharacter
	}, function(data, status) {		
		if(typeof(callback) == 'function') {
			callback();
		}
	});
}

function Attack(callback) {
	var v_message = $("#gs_char_message").val();

	$.post(actionUrl, 
	{
		action: "attack",
		message: v_message
	}, function(data, status) {		
		if(typeof(callback) == 'function') {
			callback();
		}
	});
}

function showLoadingImageInElement(element) {
	$(element).html("<img src=\"https://crux.baker.edu/~jgerma08/final/images/ajax-loader.gif\" alt=\"loading\" />");
}