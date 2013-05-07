var actionUrl = "https://crux.baker.edu/~jgerma08/cgi-bin/final/actions.cgi";
var homeUrl = "https://crux.baker.edu/~jgerma08/final/";

function CheckUniqueUsername(showLoader, result) {
	if(showLoader && typeof(result) != 'undefined') {
		showLoadingImageInElement(result);
	}
	
	$.post(actionUrl, 
	{
		action: "chkunuser",
		username: $("#gs_reg_username").val()
	}, 
	function(data, status) {
		$(result).html("");
		if(data == "1") {
			$(result).html("This username already exists!");		
		}		
	});
}

function CheckUniqueEmail(showLoader, result) {
	if(showLoader && typeof(result) != 'undefined') {
		showLoadingImageInElement(result);
	}
	
	$.post(actionUrl, 
	{
		action: "chkunemail",
		email: $("#gs_reg_email").val()
	}, 
	function(data, status) {
		$(result).html("");
		if(data == "1") {
			$(result).html("This email already exists!");		
		}		
	});
}
//chkunchname

function CheckUniqueCharacterName(showLoader, result) {
	if(showLoader && typeof(result) != 'undefined') {
		showLoadingImageInElement(result);
	}
	
	$.post(actionUrl, 
	{
		action: "chkunchname",
		cname: $("#gs_reg_charactername").val()
	}, 
	function(data, status) {
		$(result).html("");
		if(data == "1") {
			$(result).html("This character name already exists!");		
		}		
	});
}

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
		showErrorMessage(result, v_error);
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
		var resulttext = "There was an error registering. Please try again later.";
		if(data == "1")
			showSuccessMessage(result, "You've registered! Try logging in!");
		else 
			showErrorMessage(result, resulttext);
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

function CreateDeck (showLoader, result, callback) {
	if(showLoader && typeof(result) != 'undefined') {
		showLoadingImageInElement(result);
	}
	
	$.post(actionUrl, 
	{
		action: "createdeck",
		title: $("#gs_deckname").val(),
		category: $("#gs_category").val()
	}, function(data, status) {		
		showSuccessMessage(result, data);
		if(typeof(callback) == 'function') {
			callback();
		}
	});
}

function CreateFlashcard (showLoader, result, callback) {
	if(showLoader && typeof(result) != 'undefined') {
		showLoadingImageInElement(result);
	}
	
	$.post(actionUrl, 
	{
		action: "createfc",
		question: $("#gs_question").val(),
		answer: $("#gs_answer").val(),
		deckid: queryObj()["deckid"]
	}, function(data, status) {
		showSuccessMessage(result, data);
		if(typeof(callback) == 'function') {
			callback();
		}
	});
}

function CheckFlashcardAnswer(showLoader, result, callback) {
	if(showLoader && typeof(result) != 'undefined') {
		showLoadingImageInElement(result);
	}
	
	$.post(actionUrl, 
	{
		action: "chkanswer",
		answer: $("#gs_quiz_answer").val(),
		cardid: $("#hdnCardId").val(),
		deckid: queryObj()["deckid"]
	}, function(data, status) {	
		if(data == "1")
			showSuccessMessage(result, "Your answer was correct!");
		else
			showErrorMessage(result, "Sorry! Your answer was incorrect!");
		if(typeof(callback) == 'function') {
			callback();
		}
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

function showSuccessMessage(e, message) {
	$(e).addClass("success");
	$(e).css("display", "block");
	$(e).html(message);
}

function showErrorMessage(e, message) {
	$(e).addClass("error");
	$(e).css("display", "block");
	$(e).html(message);
}

function hideSysMessage(e) {
	$(e).css("display", "none");
}

function showLoadingImageInElement(element) {
	$(element).html("<img src=\"https://crux.baker.edu/~jgerma08/final/images/ajax-loader.gif\" alt=\"loading\" />");
}