#import <Preferences/Preferences.h>
#define messagesTintPath @"/User/Library/Preferences/com.joemerlino.messagestint.plist"


@interface MessagesTintPrefsListController: PSListController {
}
@end

@implementation MessagesTintPrefsListController
	- (id)specifiers {
		if(_specifiers == nil) {
			_specifiers = [[self loadSpecifiersFromPlistName:@"MessagesTintPrefs" target:self] retain];
            UIBarButtonItem *previewButton([[UIBarButtonItem alloc] initWithTitle:@"Messages" style:UIBarButtonItemStyleDone target:self action:@selector(kill:)]);
            previewButton.tag = 1;
            [[self navigationItem] setRightBarButtonItem:previewButton];
            [previewButton release];
        }
        return _specifiers;
        
        
    }
- (void)kill:(id)sender {
    system("killall -9 MobileSMS");
    sleep(1);
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"sms://"]];
}
	-(void)twitter {
		if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"twitter://user?screen_name=joe_merlino"]]) {
			[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"twitter://user?screen_name=joe_merlino"]];
		} else {
			[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://twitter.com/joe_merlino"]];
		}
	}

	-(void)my_site {
		[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://github.com/joemerlino/"]];
	}

	-(void)donate {
		[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://www.paypal.me/joemerlino/"]];
	}
	-(void) sendEmail{
		[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"mailto:merlino.giuseppe1@gmail.com?subject=MessagesTint"]];
	}
-(id) readPreferenceValue:(PSSpecifier*)specifier {
    NSDictionary *messagesTintSettings = [NSDictionary dictionaryWithContentsOfFile:messagesTintPath];
    if (!messagesTintSettings[specifier.properties[@"key"]]) {
        return specifier.properties[@"default"];
    }
    return messagesTintSettings[specifier.properties[@"key"]];
}

-(void) setPreferenceValue:(id)value specifier:(PSSpecifier*)specifier {
    NSMutableDictionary *defaults = [NSMutableDictionary dictionary];
    [defaults addEntriesFromDictionary:[NSDictionary dictionaryWithContentsOfFile:messagesTintPath]];
    [defaults setObject:value forKey:specifier.properties[@"key"]];
    [defaults writeToFile:messagesTintPath atomically:YES];
    //  NSDictionary *messagesTintSettings = [NSDictionary dictionaryWithContentsOfFile:messagesTintPath];
    CFStringRef toPost = (CFStringRef)specifier.properties[@"PostNotification"];
    if(toPost) CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), toPost, NULL, NULL, YES);
    system("killall -9 MobileSMS");
}

@end

// vim:ft=objc
