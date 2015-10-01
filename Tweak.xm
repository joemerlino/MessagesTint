#import <UIKit/UIKit.h>
//#import <ChatKit/CKComposition.h>
#import "libcolorpicker.h" 


@interface CKComposition : NSObject
@property (nonatomic,copy) NSAttributedString * text;
@property (nonatomic,readonly) BOOL hasContent;
@end

@interface UIApplication (Private)
-(id)_rootViewControllers;
@end

UIColor *iMessageColor;
UIColor *SMSColor;
UIColor *failedColor;
UIColor *unsentColor;

@interface CKNavigationBar : UINavigationBar
@end

CKNavigationBar *activeBar;
UIProgressView *progress;
UINavigationController *activeNav;
UIView *keyboard;

BOOL inConversation = false;
BOOL failed = NO;
BOOL first = YES;
BOOL transcript = YES;
BOOL activeButton;
NSAttributedString *unsent;
CKComposition * r;

@interface NSUserDefaults (Tweak_Category)
- (id)objectForKey:(NSString *)key inDomain:(NSString *)domain;
- (void)setObject:(id)value forKey:(NSString *)key inDomain:(NSString *)domain;
@end

%group MOD

%hook CKNavigationBar
- (id)initWithFrame:(CGRect)arg1 {
	[UIApplication sharedApplication].statusBarStyle = UIBarStyleBlack;
	activeBar = %orig;
	return %orig;
}
%end


%hook CKTranscriptController

- (id)initWithNavigationController:(id)arg1 {
	activeNav = arg1;
	return %orig;
}

-(UIProgressView *)progressBar{
	progress = %orig;
	if(!inConversation)
	 	inConversation = true;
	if (activeButton)
		progress.progressTintColor = [UIColor blueColor];
	else
		progress.progressTintColor = [UIColor greenColor];
	return progress;
}

- (void)viewWillDisappear:(BOOL)animated {
	%orig;
	inConversation = false;
	if(failed){	
		activeBar.barStyle = 1;
		activeNav.navigationBar.barStyle = 1;
		[activeBar setTintColor:UIColor.whiteColor];
		[activeNav.navigationBar setTintColor:UIColor.whiteColor];
		[activeBar setBarTintColor:failedColor];
		[activeNav.navigationBar setBarTintColor:failedColor];
	}
	else if(unsent != nil){
		activeBar.barStyle = 1;
		activeNav.navigationBar.barStyle = 1;
		[activeBar setTintColor:UIColor.whiteColor];
		[activeNav.navigationBar setTintColor:UIColor.whiteColor];
		[activeBar setBarTintColor:unsentColor];
		[activeNav.navigationBar setBarTintColor:unsentColor];
	}
	else{
		activeBar.barStyle = UIBarStyleDefault;
		activeNav.navigationBar.barStyle = UIBarStyleDefault;
		[activeBar setBarTintColor:nil];
		[activeBar setTintColor:nil];
		[activeNav.navigationBar setBarTintColor:nil];
		[activeNav.navigationBar setTintColor:nil];
	}
}

- (void)viewWillAppear:(BOOL)animated {
	if(failed){	
		inConversation = true;
		activeBar.barStyle = 1;
		activeNav.navigationBar.barStyle = 1;
		[activeBar setTintColor:UIColor.whiteColor];
		[activeNav.navigationBar setTintColor:UIColor.whiteColor];
		[activeBar setBarTintColor:failedColor];
		[activeNav.navigationBar setBarTintColor:failedColor];
	}
	else if(!transcript){
		inConversation = true;
		activeBar.barStyle = 1;
		activeNav.navigationBar.barStyle = 1;
		[activeBar setTintColor:UIColor.whiteColor];
		[activeNav.navigationBar setTintColor:UIColor.whiteColor];
		if (activeButton) {
			[activeBar setBarTintColor:iMessageColor];
			[activeNav.navigationBar setBarTintColor:iMessageColor];
		} else {
			[activeBar setBarTintColor:SMSColor];
			[activeNav.navigationBar setBarTintColor:SMSColor];
		}
	}
	%orig;
}
%end

%hook UIViewController
- (UIStatusBarStyle)preferredStatusBarStyle {
	return inConversation ? UIStatusBarStyleLightContent : UIStatusBarStyleDefault;
}
%end

%hook CKMessagesController
-(void)showConversation:(id)conversation animate:(BOOL)animate {
	%orig;
	inConversation = true;
	activeBar.barStyle = 1;
	activeNav.navigationBar.barStyle = 1;
	[activeBar setTintColor:UIColor.whiteColor];
	[activeNav.navigationBar setTintColor:UIColor.whiteColor];
	if (activeButton) {
		[activeBar setBarTintColor:iMessageColor];
		[activeNav.navigationBar setBarTintColor:iMessageColor];
	} else {
		[activeBar setBarTintColor:SMSColor];
		[activeNav.navigationBar setBarTintColor:SMSColor];
	}
}
%end

%hook CKMessageEntryView
- (CKComposition *)composition { 
	r = %orig; 
	unsent = r.text;
	return r; 
}
%end

%hook CKConversation

- (BOOL)sendButtonColor{
	transcript = NO;
	activeButton = %orig;
	return %orig;
}
%end

%hook CKMessagePartChatItem
- (BOOL)failed{
	failed = %orig;
	if(failed && first){
		first = NO; 
		[activeBar setBarTintColor:failedColor];
		[activeNav.navigationBar setBarTintColor:failedColor];
	}
	else if(!failed && !first){
		first = YES; 
		if (!activeButton) {
			[activeBar setBarTintColor:SMSColor];
			[activeNav.navigationBar setBarTintColor:SMSColor];
		} else {
			[activeBar setBarTintColor:iMessageColor];
			[activeNav.navigationBar setBarTintColor:iMessageColor];
		}
	}
	return %orig;
}
%end

%end

%group KEY

%hook _UIKBCompatInputView

 -(UIView *)touchableView{
 	keyboard = %orig;
 	if (failed)
		[keyboard setBackgroundColor:failedColor];
	else if (activeButton)
		[keyboard setBackgroundColor:iMessageColor];
	else
		[keyboard setBackgroundColor:SMSColor];
 	return keyboard;
 }

%end 

%end

%group SQUARE

%hook CKColoredBalloonView

-(unsigned long long)balloonCorners {
	return 0;
}

-(BOOL)hasTail {
	return NO;
}

%end

%end

static void PreferencesCallback(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo)
{
	CFPreferencesAppSynchronize(CFSTR("com.joemerlino.messagestint"));
}

%ctor {
	CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, PreferencesCallback, CFSTR("com.joemerlino.messagestint.preferencechanged"), NULL, CFNotificationSuspensionBehaviorCoalesce);
	NSMutableDictionary *prefs = [[NSMutableDictionary alloc] initWithContentsOfFile:@"/private/var/mobile/Library/Preferences/com.joemerlino.messagestint.plist"];
	BOOL enabled = ([prefs objectForKey:@"enabled"] ? [[prefs objectForKey:@"enabled"] boolValue] : YES);
	BOOL tint = ([prefs objectForKey:@"tint"] ? [[prefs objectForKey:@"tint"] boolValue] : NO);
	BOOL square = ([prefs objectForKey:@"square"] ? [[prefs objectForKey:@"square"] boolValue] : NO);
	NSLog(@"[MessagesTint] %d", enabled);   
    if (enabled) {
    	//iMessageColor = [UIColor colorWithRed:0 green:0.478431 blue:1 alpha:1];
	//SMSColor = [UIColor colorWithRed:0 green:0.8 blue:0.278431 alpha:1];

    	iMessageColor = LCPParseColorString([prefs objectForKey:@"iMessageC"], @"#007AFF");
	SMSColor = LCPParseColorString([prefs objectForKey:@"smsC"], @"#00CC47");
	unsentColor = LCPParseColorString([prefs objectForKey:@"unsentC"], @"#FF8000");
	failedColor = LCPParseColorString([prefs objectForKey:@"failedC"], @"#FF0000");

        %init(MOD);
        if(tint)
        	%init(KEY);
        if(square)
        	%init(SQUARE);
    }
}