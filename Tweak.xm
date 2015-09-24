#import <UIKit/UIKit.h>

//static NSString *domainString = @"/var/mobile/Library/Preferences/com.joemerlino.messagestint.plist";

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
	else {
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

%hook CKTranscriptCollectionViewController
- (void)_resendMessageAtIndexPath:(id)arg1{
	NSLog(@"[MessagesTint] resend");
	%orig;
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
- (BOOL)canSendToRecipients:(id)arg1 alertIfUnable:(BOOL)arg2{
	NSLog(@"[MessagesTint] unable %d", arg2);
	return %orig;

}

- (BOOL)sendButtonColor{
	NSLog(@"[MessagesTint] color %d", %orig);
	activeButton = %orig;
	return %orig;
}
%end
/*
%hook CKBalloonChatItem
- (BOOL)failed{
	failed = %orig;
	NSLog(@"[MessagesTint] failed %d",%orig);
	
	if(failed && first){
		[[NSUserDefaults standardUserDefaults] setObject:@"YES" forKey:@"failed" inDomain:domainString];
		first = NO; 
		NSLog(@"[MessagesTint] failed %d",%orig);
		[activeBar setBarTintColor:UIColor.redColor];
		[activeNav.navigationBar setBarTintColor:UIColor.redColor];
	}
	else if(!failed && !first){
		[[NSUserDefaults standardUserDefaults] setObject:@"NO" forKey:@"failed" inDomain:domainString];
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
*/
%end

static void PreferencesCallback(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo)
{
	CFPreferencesAppSynchronize(CFSTR("com.joemerlino.messagestint"));
}

%ctor {
	CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, PreferencesCallback, CFSTR("com.joemerlino.messagestint.preferencechanged"), NULL, CFNotificationSuspensionBehaviorCoalesce);
	NSMutableDictionary *prefs = [[NSMutableDictionary alloc] initWithContentsOfFile:@"/private/var/mobile/Library/Preferences/com.joemerlino.messagestint.plist"];
	BOOL enabled = ([prefs objectForKey:@"enabled"] ? [[prefs objectForKey:@"enabled"] boolValue] : YES);
	failed = ([prefs objectForKey:@"failed"] ? [[prefs objectForKey:@"failed"] boolValue] : NO);
	NSLog(@"[MessagesTint] %d %d", enabled, failed);   
    if (enabled) {
    	iMessageColor = [UIColor colorWithRed:0 green:0.478431 blue:1 alpha:1];
		SMSColor = [UIColor colorWithRed:0 green:0.8 blue:0.278431 alpha:1];
		grayColor = [UIColor colorWithRed:0.556863 green:0.556863 blue:0.576471 alpha:1];
        %init(MOD);
    }
}