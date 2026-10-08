// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for an en locale. All the
// messages from the main program should be duplicated here with the same
// function name.

// Ignore issues from commonly used lints in this file.
// ignore_for_file:unnecessary_brace_in_string_interps, unnecessary_new
// ignore_for_file:prefer_single_quotes,comment_references, directives_ordering
// ignore_for_file:annotate_overrides,prefer_generic_function_type_aliases
// ignore_for_file:unused_import, file_names, avoid_escaping_inner_quotes
// ignore_for_file:unnecessary_string_interpolations, unnecessary_string_escapes

import 'package:intl/intl.dart';
import 'package:intl/message_lookup_by_library.dart';

final messages = new MessageLookup();

typedef String MessageIfAbsent(String messageStr, List<dynamic> args);

class MessageLookup extends MessageLookupByLibrary {
  String get localeName => 'en';

  static String m0(minutes, seconds) => "${minutes}:${seconds}";

  static String m1(status) => "${status}";

  static String m2(days) => "Number of days remaining: ${days} days";

  static String m3(id) => "member to block >>>> ${id}";

  static String m4(count) => "${count} Engaged People";

  static String m5(count, members) => "${count} = ${members}";

  static String m6(musicName) => "Now Playing: ${musicName}";

  static String m7(count) => "Number of stars ${count}";

  static String m8(status) => "${status}";

  static String m9(musicName) => "Play ${musicName}";

  static String m10(count) => "+${count}";

  static String m11(count) => "Selected Times: ${count}";

  static String m12(musicName) => "Stop ${musicName}";

  static String m13(uid) => "User ${uid}";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
        "Active": MessageLookupByLibrary.simpleMessage("Active"),
        "Inactive": MessageLookupByLibrary.simpleMessage("Inactive"),
        "accept": MessageLookupByLibrary.simpleMessage("Accept"),
        "accountInformation":
            MessageLookupByLibrary.simpleMessage("Account Information"),
        "addCustom": MessageLookupByLibrary.simpleMessage("Add Custom"),
        "addNewChat": MessageLookupByLibrary.simpleMessage("Add a new chat"),
        "addParticipant":
            MessageLookupByLibrary.simpleMessage("Add Participant"),
        "admin": MessageLookupByLibrary.simpleMessage("Admin"),
        "afterPurchase": MessageLookupByLibrary.simpleMessage("After Purchase"),
        "alert": MessageLookupByLibrary.simpleMessage("Alert"),
        "allMembersLoaded":
            MessageLookupByLibrary.simpleMessage("All members loaded"),
        "another_chats": MessageLookupByLibrary.simpleMessage("Another Chats"),
        "arabic": MessageLookupByLibrary.simpleMessage("Arabic"),
        "audioCall": MessageLookupByLibrary.simpleMessage("Audio Call"),
        "audioTimerFormat": m0,
        "audiocall": MessageLookupByLibrary.simpleMessage("Audio Call"),
        "availableTimes":
            MessageLookupByLibrary.simpleMessage("Available Times"),
        "back": MessageLookupByLibrary.simpleMessage("Back"),
        "backgroundMusic":
            MessageLookupByLibrary.simpleMessage("Background Music"),
        "binance": MessageLookupByLibrary.simpleMessage("Binance"),
        "block": MessageLookupByLibrary.simpleMessage("Block"),
        "butterfly": MessageLookupByLibrary.simpleMessage("Butterfly"),
        "buyOrSendStars":
            MessageLookupByLibrary.simpleMessage("Buy or send stars"),
        "call": MessageLookupByLibrary.simpleMessage("Call"),
        "cameraOff": MessageLookupByLibrary.simpleMessage("Camera Off"),
        "cancel": MessageLookupByLibrary.simpleMessage("Cancel"),
        "capabilities": MessageLookupByLibrary.simpleMessage("Capabilities"),
        "chargeStars":
            MessageLookupByLibrary.simpleMessage("Charge the stars from here"),
        "chargeStarsNow":
            MessageLookupByLibrary.simpleMessage("Charge stars now"),
        "chat_1": MessageLookupByLibrary.simpleMessage("Chat 1"),
        "chat_2": MessageLookupByLibrary.simpleMessage("Chat 2"),
        "chat_3": MessageLookupByLibrary.simpleMessage("Chat 3"),
        "chats": MessageLookupByLibrary.simpleMessage("Chats"),
        "chooseAdmin": MessageLookupByLibrary.simpleMessage("Choose Admins"),
        "chooseChatFormat":
            MessageLookupByLibrary.simpleMessage("Choose a Chat Format"),
        "chooseChatToPin": MessageLookupByLibrary.simpleMessage(
            "Choose what chat you want to pin"),
        "choosePaymentMethod": MessageLookupByLibrary.simpleMessage(
            "Choose the appropriate payment method"),
        "chooseWhatYouWantToPlay": MessageLookupByLibrary.simpleMessage(
            "Choose what you want to play"),
        "close": MessageLookupByLibrary.simpleMessage("Close"),
        "closeCall":
            MessageLookupByLibrary.simpleMessage("This call was closed .."),
        "closeEnergy": MessageLookupByLibrary.simpleMessage("Close Energy"),
        "colors": MessageLookupByLibrary.simpleMessage("Colors"),
        "confirm": MessageLookupByLibrary.simpleMessage("Confirm"),
        "confirmDeleteCustomTheme": MessageLookupByLibrary.simpleMessage(
            "Are you sure you want to delete this custom theme?"),
        "confirmPurchase":
            MessageLookupByLibrary.simpleMessage("Confirm Purchase"),
        "connecting": MessageLookupByLibrary.simpleMessage("Connecting..."),
        "connectionError":
            MessageLookupByLibrary.simpleMessage("Connection Error"),
        "connectionFailed":
            MessageLookupByLibrary.simpleMessage("Connection Failed"),
        "connectionStatus": m1,
        "correspondent": MessageLookupByLibrary.simpleMessage("Correspondent"),
        "create": MessageLookupByLibrary.simpleMessage("Create"),
        "createAccount": MessageLookupByLibrary.simpleMessage("Create Account"),
        "createNewChat":
            MessageLookupByLibrary.simpleMessage("Create a new chat"),
        "createNow": MessageLookupByLibrary.simpleMessage("Create Now"),
        "create_account":
            MessageLookupByLibrary.simpleMessage("Create Account"),
        "creating_chat": MessageLookupByLibrary.simpleMessage("Creating chat"),
        "currentlyPlaying":
            MessageLookupByLibrary.simpleMessage("Currently Playing"),
        "darkMode": MessageLookupByLibrary.simpleMessage("Dark Mode"),
        "darkModeEnabled":
            MessageLookupByLibrary.simpleMessage("Dark mode is enabled"),
        "date": MessageLookupByLibrary.simpleMessage("Enter Date 00-00-0000"),
        "days": MessageLookupByLibrary.simpleMessage("day"),
        "daysRemaining": m2,
        "debugMemberBlock": m3,
        "deletAccMsg": MessageLookupByLibrary.simpleMessage(
            "Are you sure you want to delete your account ?"),
        "delete": MessageLookupByLibrary.simpleMessage("Delete"),
        "deleteAccount": MessageLookupByLibrary.simpleMessage("Delete Account"),
        "deleteCustomTheme":
            MessageLookupByLibrary.simpleMessage("Delete Custom Theme"),
        "descriptionLink":
            MessageLookupByLibrary.simpleMessage("Description Link"),
        "edit": MessageLookupByLibrary.simpleMessage("Edit"),
        "editInformation":
            MessageLookupByLibrary.simpleMessage("Edit Information"),
        "email": MessageLookupByLibrary.simpleMessage("Email"),
        "emailError":
            MessageLookupByLibrary.simpleMessage("The Email is invalid"),
        "endCall": MessageLookupByLibrary.simpleMessage("End Call"),
        "engagedPeople": m4,
        "engaged_people":
            MessageLookupByLibrary.simpleMessage("Engaged People"),
        "english": MessageLookupByLibrary.simpleMessage("English"),
        "englishLanguageSelected":
            MessageLookupByLibrary.simpleMessage("English language selected"),
        "enterAge": MessageLookupByLibrary.simpleMessage("Enter your age"),
        "enterCodeSent":
            MessageLookupByLibrary.simpleMessage("Enter the code sent"),
        "enterCountry":
            MessageLookupByLibrary.simpleMessage("Enter your country"),
        "enterEmail": MessageLookupByLibrary.simpleMessage("Enter your email"),
        "enterEmailAddress":
            MessageLookupByLibrary.simpleMessage("Enter your email address"),
        "enterEmailToComplete": MessageLookupByLibrary.simpleMessage(
            "Enter the email to complete the registration process"),
        "enterFullName":
            MessageLookupByLibrary.simpleMessage("Enter your full name"),
        "enterMobileNumber":
            MessageLookupByLibrary.simpleMessage("Enter your mobile number"),
        "enterUsername":
            MessageLookupByLibrary.simpleMessage("Enter your username"),
        "enter_email_to_complete": MessageLookupByLibrary.simpleMessage(
            "Enter the email to complete the registration process"),
        "enter_the_code_sent":
            MessageLookupByLibrary.simpleMessage("Enter the code sent"),
        "enter_your_email_address":
            MessageLookupByLibrary.simpleMessage("Enter your email address"),
        "error": MessageLookupByLibrary.simpleMessage("Error"),
        "errorBuyStars": MessageLookupByLibrary.simpleMessage(
            "Not enough stars. Please buy stars"),
        "errorLogin":
            MessageLookupByLibrary.simpleMessage("please login again .."),
        "errorPin": MessageLookupByLibrary.simpleMessage(
            "The date field must match the format Y-m-d. or The date field must be a date after or equal to today"),
        "error_picking_image":
            MessageLookupByLibrary.simpleMessage("Error picking image"),
        "exit": MessageLookupByLibrary.simpleMessage("Exit"),
        "exitConfirmation":
            MessageLookupByLibrary.simpleMessage("Are you want to exit app?"),
        "failedToLoadRadioStations": MessageLookupByLibrary.simpleMessage(
            "Failed to load radio stations"),
        "failed_to_load_user_data":
            MessageLookupByLibrary.simpleMessage("Failed to load user data"),
        "failed_to_pick_image":
            MessageLookupByLibrary.simpleMessage("Failed to pick image"),
        "failed_to_save_profile":
            MessageLookupByLibrary.simpleMessage("Failed to save profile"),
        "female": MessageLookupByLibrary.simpleMessage("Female"),
        "fillAllFields":
            MessageLookupByLibrary.simpleMessage("Please fill all fields"),
        "fillDetailsTwoSteps": MessageLookupByLibrary.simpleMessage(
            "Fill in the details, 2 steps remaining"),
        "fillDetailsZeroSteps": MessageLookupByLibrary.simpleMessage(
            "Fill in the details, only 0 steps remaining"),
        "fillInfoOneStep": MessageLookupByLibrary.simpleMessage(
            "Fill in the information, 1 step remaining"),
        "fill_in_details_two_steps": MessageLookupByLibrary.simpleMessage(
            "Fill in the details, 2 steps remaining"),
        "fill_in_details_zero_steps": MessageLookupByLibrary.simpleMessage(
            "Fill in the details, only 0 steps remaining"),
        "fill_in_information_one_step": MessageLookupByLibrary.simpleMessage(
            "Fill in the information, 1 step remaining"),
        "first_page": MessageLookupByLibrary.simpleMessage("First Page"),
        "flowerOfWorld":
            MessageLookupByLibrary.simpleMessage("Flower of the World"),
        "format_colon": MessageLookupByLibrary.simpleMessage("Format"),
        "friend": MessageLookupByLibrary.simpleMessage("friend"),
        "friendRequestAcceptedBody": MessageLookupByLibrary.simpleMessage(
            "The friend request you sent to "),
        "friendRequestBody": MessageLookupByLibrary.simpleMessage("sent you "),
        "friendRequestTitle":
            MessageLookupByLibrary.simpleMessage("Friend Request"),
        "full_name": MessageLookupByLibrary.simpleMessage("Full Name"),
        "general": MessageLookupByLibrary.simpleMessage("General"),
        "genericError": MessageLookupByLibrary.simpleMessage("Error"),
        "groupAudioCall":
            MessageLookupByLibrary.simpleMessage("Groub Audio Call"),
        "groupVideoCall":
            MessageLookupByLibrary.simpleMessage("Group Video Call"),
        "hello": MessageLookupByLibrary.simpleMessage("Hello,"),
        "help": MessageLookupByLibrary.simpleMessage("Help"),
        "howToBeWhiteAngel":
            MessageLookupByLibrary.simpleMessage("How to be a white angel"),
        "httpFaraena": MessageLookupByLibrary.simpleMessage("Http/faraena.com"),
        "image": MessageLookupByLibrary.simpleMessage("Image"),
        "imageViewerTitle": MessageLookupByLibrary.simpleMessage(""),
        "image_colon": MessageLookupByLibrary.simpleMessage("Image"),
        "info": MessageLookupByLibrary.simpleMessage("Info"),
        "instapay": MessageLookupByLibrary.simpleMessage("Instapay"),
        "insufficientStars":
            MessageLookupByLibrary.simpleMessage("Insufficient Stars"),
        "inviteFriends": MessageLookupByLibrary.simpleMessage("Invite Friends"),
        "isBuy": MessageLookupByLibrary.simpleMessage("Purchased"),
        "joinChatBody":
            MessageLookupByLibrary.simpleMessage("joined the chat:"),
        "joinNow": MessageLookupByLibrary.simpleMessage("Join Now"),
        "join_now": MessageLookupByLibrary.simpleMessage("Join Now"),
        "joining": MessageLookupByLibrary.simpleMessage("Joining ..."),
        "kareemElsayed": MessageLookupByLibrary.simpleMessage("Kareem Elsayed"),
        "language": MessageLookupByLibrary.simpleMessage("Language"),
        "latestChats": MessageLookupByLibrary.simpleMessage("Latest Chats"),
        "latest_chats": MessageLookupByLibrary.simpleMessage("Latest Chats"),
        "lightMode": MessageLookupByLibrary.simpleMessage("Light Mode"),
        "linkCopied": MessageLookupByLibrary.simpleMessage("Link copied"),
        "loadMoreChats":
            MessageLookupByLibrary.simpleMessage("Load more chats..."),
        "loading": MessageLookupByLibrary.simpleMessage("Loading..."),
        "loadingPayment":
            MessageLookupByLibrary.simpleMessage("loading Payment"),
        "logOut": MessageLookupByLibrary.simpleMessage("Log Out"),
        "log_in": MessageLookupByLibrary.simpleMessage("Log In"),
        "login": MessageLookupByLibrary.simpleMessage("Login"),
        "male": MessageLookupByLibrary.simpleMessage("Male"),
        "manager_colon": MessageLookupByLibrary.simpleMessage("Manager"),
        "member": MessageLookupByLibrary.simpleMessage("Member"),
        "memberOfLoversChat":
            MessageLookupByLibrary.simpleMessage("Member of the Lovers' Chat"),
        "members": MessageLookupByLibrary.simpleMessage("Members"),
        "membersCount": m5,
        "membersOfChat":
            MessageLookupByLibrary.simpleMessage("Member of the Pharaohs chat"),
        "microphonePermissionRequired": MessageLookupByLibrary.simpleMessage(
            "Microphone Permission Required"),
        "more": MessageLookupByLibrary.simpleMessage("More"),
        "movements": MessageLookupByLibrary.simpleMessage("Movements"),
        "msgBlockUser": MessageLookupByLibrary.simpleMessage(
            "You are blocked by that user"),
        "msgIBlock":
            MessageLookupByLibrary.simpleMessage("You block that user"),
        "music": MessageLookupByLibrary.simpleMessage("Music"),
        "musicPlayerClose": MessageLookupByLibrary.simpleMessage("Close Music"),
        "mute": MessageLookupByLibrary.simpleMessage("Mute"),
        "muted": MessageLookupByLibrary.simpleMessage("Muted"),
        "myAccount": MessageLookupByLibrary.simpleMessage("My Account"),
        "name": MessageLookupByLibrary.simpleMessage("Name"),
        "name_cannot_be_empty":
            MessageLookupByLibrary.simpleMessage("Name cannot be empty"),
        "networkGood": MessageLookupByLibrary.simpleMessage("Good"),
        "newChat": MessageLookupByLibrary.simpleMessage("New chat"),
        "next": MessageLookupByLibrary.simpleMessage("Next"),
        "nightMode": MessageLookupByLibrary.simpleMessage("Night Mode"),
        "no": MessageLookupByLibrary.simpleMessage("No"),
        "noChat": MessageLookupByLibrary.simpleMessage("No Chat Yet"),
        "noInternet":
            MessageLookupByLibrary.simpleMessage("please check your internet"),
        "noMembers": MessageLookupByLibrary.simpleMessage("No memberes yet"),
        "noMembersFound":
            MessageLookupByLibrary.simpleMessage("No members found"),
        "noNotifications":
            MessageLookupByLibrary.simpleMessage("There are no notifications."),
        "noNotificationsDescription": MessageLookupByLibrary.simpleMessage(
            "All notifications will appear here...\nIn case something new happens."),
        "noPowersAvailable":
            MessageLookupByLibrary.simpleMessage("No Power Avialable"),
        "notFriend":
            MessageLookupByLibrary.simpleMessage("Send a friend request"),
        "notFriendRequest":
            MessageLookupByLibrary.simpleMessage("Not find friends requests"),
        "notifications": MessageLookupByLibrary.simpleMessage("Notifications"),
        "notificationsDisabled":
            MessageLookupByLibrary.simpleMessage("Notifications disabled"),
        "notificationsEnabled":
            MessageLookupByLibrary.simpleMessage("Notifications enabled"),
        "nowPlaying": m6,
        "numberOfStars":
            MessageLookupByLibrary.simpleMessage("Number of stars"),
        "numberOfStarsCount": m7,
        "openSettings": MessageLookupByLibrary.simpleMessage("Open Settings"),
        "other": MessageLookupByLibrary.simpleMessage("Other"),
        "otherChats": MessageLookupByLibrary.simpleMessage("Other Chats"),
        "other_chats": MessageLookupByLibrary.simpleMessage("Other Chats"),
        "otpError": MessageLookupByLibrary.simpleMessage("The OTP is invalid"),
        "owner": MessageLookupByLibrary.simpleMessage("Owner"),
        "ownerBadge": MessageLookupByLibrary.simpleMessage("OWNER"),
        "participants": MessageLookupByLibrary.simpleMessage("participants"),
        "paymentFailed": MessageLookupByLibrary.simpleMessage("payment Failed"),
        "paymentLoadingError":
            MessageLookupByLibrary.simpleMessage("payment Loading Error"),
        "paymentSuccessful":
            MessageLookupByLibrary.simpleMessage("Payment was successful!"),
        "paymentUnderReview": MessageLookupByLibrary.simpleMessage(
            "The payment is under review by administrators."),
        "perfectMoney": MessageLookupByLibrary.simpleMessage("Perfect Money"),
        "permissionRequiredMessage": MessageLookupByLibrary.simpleMessage(
            "This app needs microphone permission for audio calls. Please enable it in settings."),
        "permissionStatus": m8,
        "pinYourChat": MessageLookupByLibrary.simpleMessage("Pin your chat"),
        "playMusic": m9,
        "playbackError": MessageLookupByLibrary.simpleMessage("Playback error"),
        "playing": MessageLookupByLibrary.simpleMessage("Playing"),
        "pleaseEnterEmail":
            MessageLookupByLibrary.simpleMessage("Please, Enter your email"),
        "pleaseEnterName":
            MessageLookupByLibrary.simpleMessage("Please, Enter your name"),
        "pleaseEnterValidEmail":
            MessageLookupByLibrary.simpleMessage("Please, Enter valid email"),
        "pleaseFillAllFields":
            MessageLookupByLibrary.simpleMessage("Please fill all fields"),
        "pleaseLoginToAccess":
            MessageLookupByLibrary.simpleMessage("Please login to access"),
        "pleasePurchaseMoreStars": MessageLookupByLibrary.simpleMessage(
            "Please purchase more stars to complete this purchase."),
        "please_enter_valid_age":
            MessageLookupByLibrary.simpleMessage("Please enter a valid age"),
        "please_enter_valid_email":
            MessageLookupByLibrary.simpleMessage("Please, Enter valid email"),
        "please_enter_your_email":
            MessageLookupByLibrary.simpleMessage("Please, Enter your email"),
        "please_enter_your_name":
            MessageLookupByLibrary.simpleMessage("Please, Enter your name"),
        "points": MessageLookupByLibrary.simpleMessage("points"),
        "positiveChat": MessageLookupByLibrary.simpleMessage("Positive Chat"),
        "positive_chat": MessageLookupByLibrary.simpleMessage("Pin Chat"),
        "power": MessageLookupByLibrary.simpleMessage("Power"),
        "price": MessageLookupByLibrary.simpleMessage("Price"),
        "privacy": MessageLookupByLibrary.simpleMessage("Privacy"),
        "privacy_colon": MessageLookupByLibrary.simpleMessage("Privacy"),
        "private": MessageLookupByLibrary.simpleMessage("Private"),
        "procedure": MessageLookupByLibrary.simpleMessage("Procedure"),
        "profile": MessageLookupByLibrary.simpleMessage("Profile"),
        "profile_updated_successfully": MessageLookupByLibrary.simpleMessage(
            "Profile updated successfully"),
        "public": MessageLookupByLibrary.simpleMessage("Public"),
        "purchase": MessageLookupByLibrary.simpleMessage("Purchase"),
        "purchaseFailed": MessageLookupByLibrary.simpleMessage(
            "Purchase failed. Please try again."),
        "radio": MessageLookupByLibrary.simpleMessage("Radio"),
        "radioStations": MessageLookupByLibrary.simpleMessage("Radio Stations"),
        "react": MessageLookupByLibrary.simpleMessage("React to message"),
        "reactionCount": m10,
        "reactions": MessageLookupByLibrary.simpleMessage("Reactions"),
        "registerError":
            MessageLookupByLibrary.simpleMessage("Username Or Email is used"),
        "reminingTime": MessageLookupByLibrary.simpleMessage("Duration"),
        "renewal": MessageLookupByLibrary.simpleMessage("Renewal"),
        "requestToSend": MessageLookupByLibrary.simpleMessage("Requests"),
        "requestWaiting": MessageLookupByLibrary.simpleMessage(
            "Friend request send successfully"),
        "requests": MessageLookupByLibrary.simpleMessage("Friends Requests"),
        "resend": MessageLookupByLibrary.simpleMessage("Resend"),
        "retry": MessageLookupByLibrary.simpleMessage("Retry"),
        "roomImage": MessageLookupByLibrary.simpleMessage("Room Image"),
        "sakuya": MessageLookupByLibrary.simpleMessage("Sakuya"),
        "save": MessageLookupByLibrary.simpleMessage("Save"),
        "saveChanges": MessageLookupByLibrary.simpleMessage("Save Changes"),
        "search": MessageLookupByLibrary.simpleMessage("Search"),
        "selectCan": MessageLookupByLibrary.simpleMessage("Request to chat"),
        "selectGender":
            MessageLookupByLibrary.simpleMessage("Select your gender"),
        "selectManager": MessageLookupByLibrary.simpleMessage(
            "Select a Manager from the Members"),
        "selectPrivateOrPublic":
            MessageLookupByLibrary.simpleMessage("Select Private or Public"),
        "selectedTimes": m11,
        "send": MessageLookupByLibrary.simpleMessage("Send"),
        "sendToYouRequest":
            MessageLookupByLibrary.simpleMessage("Sent you a friend request"),
        "sendYourMessage":
            MessageLookupByLibrary.simpleMessage("Send your message..."),
        "sending": MessageLookupByLibrary.simpleMessage("Sending..."),
        "sentSuccessfully":
            MessageLookupByLibrary.simpleMessage("Sent successfully!"),
        "serverError": MessageLookupByLibrary.simpleMessage("Server Error"),
        "settings": MessageLookupByLibrary.simpleMessage("Settings"),
        "settingsOfChat":
            MessageLookupByLibrary.simpleMessage("Settings of chat"),
        "share": MessageLookupByLibrary.simpleMessage("Share"),
        "slideToCancel":
            MessageLookupByLibrary.simpleMessage("Slide To Cancel"),
        "somethingWentWrong":
            MessageLookupByLibrary.simpleMessage("Something went wrong"),
        "sonder": MessageLookupByLibrary.simpleMessage("Sonder"),
        "splashText": MessageLookupByLibrary.simpleMessage(
            "Created with love from Athar to the world"),
        "star": MessageLookupByLibrary.simpleMessage("star"),
        "stars": MessageLookupByLibrary.simpleMessage("stars"),
        "starsSentSuccessfully": MessageLookupByLibrary.simpleMessage(
            "The stars have been sent successfully."),
        "startCreatingNewWorld":
            MessageLookupByLibrary.simpleMessage("Start creating a new world"),
        "startVideo": MessageLookupByLibrary.simpleMessage("Start Video"),
        "status": MessageLookupByLibrary.simpleMessage("status"),
        "stopMusic": m12,
        "stopVideo": MessageLookupByLibrary.simpleMessage("Stop Video"),
        "style_1": MessageLookupByLibrary.simpleMessage("Style 1"),
        "style_2": MessageLookupByLibrary.simpleMessage("Style 2"),
        "style_3": MessageLookupByLibrary.simpleMessage("Style 3"),
        "style_4": MessageLookupByLibrary.simpleMessage("Style 4"),
        "style_5": MessageLookupByLibrary.simpleMessage("Style 5"),
        "style_6": MessageLookupByLibrary.simpleMessage("Style 6"),
        "style_7": MessageLookupByLibrary.simpleMessage("Style 7"),
        "success": MessageLookupByLibrary.simpleMessage("Success"),
        "msgUnblockedSuccessfully":
            MessageLookupByLibrary.simpleMessage("Unblocked successfully"),
        "successResend":
            MessageLookupByLibrary.simpleMessage("Success resend OTP"),
        "succsesPin":
            MessageLookupByLibrary.simpleMessage("Your request under review"),
        "suggestedFriends":
            MessageLookupByLibrary.simpleMessage("Suggested Friends"),
        "sureToBlock": MessageLookupByLibrary.simpleMessage(
            "Are you sure you want to block this user ?"),
        "switchCamera": MessageLookupByLibrary.simpleMessage("Switch Camera"),
        "termsAndConditions":
            MessageLookupByLibrary.simpleMessage("Terms and Conditions"),
        "theGreatPharaohs":
            MessageLookupByLibrary.simpleMessage("The Great Pharaohs"),
        "the_great_pharaohs":
            MessageLookupByLibrary.simpleMessage("The Great Pharaohs"),
        "time": MessageLookupByLibrary.simpleMessage("00:00 Enter Time"),
        "timeToPIN": MessageLookupByLibrary.simpleMessage(
            "00:00 Enter time want to pin"),
        "timeoutError": MessageLookupByLibrary.simpleMessage("Time Out Error"),
        "title": MessageLookupByLibrary.simpleMessage("Title"),
        "titles": MessageLookupByLibrary.simpleMessage("Titles"),
        "unBlock": MessageLookupByLibrary.simpleMessage("Unblock"),
        "unauthorizedError":
            MessageLookupByLibrary.simpleMessage("Unauthorized Error"),
        "unmute": MessageLookupByLibrary.simpleMessage("Unmute"),
        "unprocessableError":
            MessageLookupByLibrary.simpleMessage("Unprocessable Error"),
        "updateChat": MessageLookupByLibrary.simpleMessage("Update Chat"),
        "update_chat": MessageLookupByLibrary.simpleMessage("Update Chat"),
        "updated_chats": MessageLookupByLibrary.simpleMessage("Latest Chats"),
        "useEarpiece": MessageLookupByLibrary.simpleMessage("Use Earpiece"),
        "useSpeaker": MessageLookupByLibrary.simpleMessage("Use Speaker"),
        "user": m13,
        "userName": MessageLookupByLibrary.simpleMessage("User Name"),
        "userNameError": MessageLookupByLibrary.simpleMessage(
            "please enter another username"),
        "user_a": MessageLookupByLibrary.simpleMessage("User A"),
        "user_b": MessageLookupByLibrary.simpleMessage("User B"),
        "user_c": MessageLookupByLibrary.simpleMessage("User C"),
        "verify": MessageLookupByLibrary.simpleMessage("Verify"),
        "verifyEmailOwner": MessageLookupByLibrary.simpleMessage(
            "You must verify that you are the owner of the email"),
        "video": MessageLookupByLibrary.simpleMessage("Video"),
        "videoCall": MessageLookupByLibrary.simpleMessage("Video Call"),
        "videoOff": MessageLookupByLibrary.simpleMessage("Video Off"),
        "videocall": MessageLookupByLibrary.simpleMessage("Video Call"),
        "vodafoneCash": MessageLookupByLibrary.simpleMessage("Vodafone Cash"),
        "voiceMessage": MessageLookupByLibrary.simpleMessage("Voice Message"),
        "waitAccept": MessageLookupByLibrary.simpleMessage(
            "Wait for accept to join this caht"),
        "waitForAccept": MessageLookupByLibrary.simpleMessage(
            "Please wait until you are allowed to send messages."),
        "waitingForConfirmation": MessageLookupByLibrary.simpleMessage(
            "We are waiting for your confirmation again!!"),
        "waitingForOthers": MessageLookupByLibrary.simpleMessage(
            "Waiting for others to join..."),
        "walletNumber": MessageLookupByLibrary.simpleMessage(
            "Wallet number: e.g. 0111111111"),
        "wantToPinAdd":
            MessageLookupByLibrary.simpleMessage("Want to pin an add?"),
        "wantToSendMsg": MessageLookupByLibrary.simpleMessage(
            "That user want to send you message"),
        "warning": MessageLookupByLibrary.simpleMessage("Warning"),
        "willBeLoggedOut": MessageLookupByLibrary.simpleMessage(
            "You will be logged out after pressing Confirm .."),
        "yes": MessageLookupByLibrary.simpleMessage("Yes"),
        "you": MessageLookupByLibrary.simpleMessage("You"),
        "you_must_verify_email": MessageLookupByLibrary.simpleMessage(
            "You must verify that you are the owner of the email"),
        "yourFriends": MessageLookupByLibrary.simpleMessage("Your friends"),
        "yourPrivateChats":
            MessageLookupByLibrary.simpleMessage("Your private chats"),
        "mayolivechat": MessageLookupByLibrary.simpleMessage(
            "Mayo Live Chat\nExperience it Live"),
      };
}
