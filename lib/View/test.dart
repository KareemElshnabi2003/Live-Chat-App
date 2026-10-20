
//https://ngoumapp.com/.well-known/assetlinks.json



//https://ngoumapp.com/.well-known/apple-app-site-association



/*

) ارفع الملف على https://ngoumapp.com/.well-known/assetlinks.json، وبعدين تأكد إن الفحص عدى:

adb shell pm verify-app-links --re-verify com.liveChat.app
adb shell pm get-app-links com.liveChat.app

لو طلعلك verified قدام ngoumapp.com، يبقى تمام. لو طلعلك legacy_failure أو حاجة تانية، يبقى فيه مشكلة في الملف أو الاستضافة.

بعد كده ابعتلك نفسك اللينك على واتساب/تليجرام/Notes ودوس عليه — المفروض يفتح التطبيق على طول على نفس الشات، من غير ما تمر بالمتصفح خالص.

 */
 


// done test link >>> when publish  app on google play edit sha250
//  apple not upload on server and not make it 
/* 
api/v1/get-conversation-by-id/{conversation}
*/