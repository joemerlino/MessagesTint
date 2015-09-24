#import <UIKit/UIKit.h>

@interface UIApplication (Private)
-(id)_rootViewControllers;
@end

UIColor *iMessageColor;
UIColor *SMSColor;
UIColor *grayColor;

@interface CKNavigationBar : UINavigationBar
@end

CKNavigationBar *activeBar;
UIProgressView *progress;
UINavigationController *activeNav;

BOOL inConversation = false;
BOOL failed = NO;
BOOL first = YES;
BOOL transcript = YES;
BOOL activeButton;

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
	NSLog(@"[MessagesTint] viewWillDisappear %d", failed);
	%orig;
	inConversation = false;
	if(failed){	
		activeBar.barStyle = 1;
		activeNav.navigationBar.barStyle = 1;
		[activeBar setTintColor:UIColor.whiteColor];
		[activeNav.navigationBar setTintColor:UIColor.whiteColor];
		[activeBar setBarTintColor:UIColor.redColor];
		[activeNav.navigationBar setBarTintColor:UIColor.redColor];
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
		[activeBar setBarTintColor:UIColor.redColor];
		[activeNav.navigationBar setBarTintColor:UIColor.redColor];
	}
	else if(!transcript){
		NSLog(@"[MessagesTint] viewWillAppear %d", failed);
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
	NSLog(@"[MessagesTint] showConversation");
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

%hook CKConversation

- (BOOL)sendButtonColor{
	NSLog(@"[MessagesTint] color %d", %orig);
	transcript = NO;
	activeButton = %orig;
	return %orig;
}
%end

%hook CKMessagePartChatItem
- (BOOL)failed{
	failed = %orig;
	NSLog(@"[MessagesTint] failed %d",%orig);
	
	if(failed && first){
		first = NO; 
		NSLog(@"[MessagesTint] failed %d",%orig);
		[activeBar setBarTintColor:UIColor.redColor];
		[activeNav.navigationBar setBarTintColor:UIColor.redColor];
	}
	else if(!failed && !first){
		first = YES; 
		NSLog(@"[MessagesTint] failed %d",%orig);
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

static void PreferencesCallback(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo)
{
	CFPreferencesAppSynchronize(CFSTR("com.joemerlino.messagestint"));
}

%ctor {
	CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, PreferencesCallback, CFSTR("com.joemerlino.messagestint.preferencechanged"), NULL, CFNotificationSuspensionBehaviorCoalesce);
	NSMutableDictionary *prefs = [[NSMutableDictionary alloc] initWithContentsOfFile:@"/private/var/mobile/Library/Preferences/com.joemerlino.messagestint.plist"];
	BOOL enabled = ([prefs objectForKey:@"enabled"] ? [[prefs objectForKey:@"enabled"] boolValue] : YES);
	NSLog(@"[MessagesTint] %d", enabled);   
    if (enabled) {
    	iMessageColor = [UIColor colorWithRed:0 green:0.478431 blue:1 alpha:1];
		SMSColor = [UIColor colorWithRed:0 green:0.8 blue:0.278431 alpha:1];
        %init(MOD);
    }
}