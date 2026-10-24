#import "ViewController.h"
#import <ExternalAccessory/ExternalAccessory.h>

@interface ViewController ()

@property (nonatomic, strong) UIView *sidebar;
@property (nonatomic, strong) UIView *toolbar;
@property (nonatomic, strong) UIView *contentView;

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *connectionLabel;
@property (nonatomic, strong) UILabel *deviceNameLabel;
@property (nonatomic, strong) UILabel *deviceDetailsLabel;
@property (nonatomic, strong) UILabel *statusLabel;
@property (nonatomic, strong) UILabel *lastScanLabel;

@property (nonatomic, strong) UIView *deviceIconView;
@property (nonatomic, strong) UIImageView *deviceIcon;
@property (nonatomic, strong) UIView *statusIndicator;

@property (nonatomic, strong) UIButton *scanButton;
@property (nonatomic, strong) UIButton *restoreButton;
@property (nonatomic, strong) UIButton *recoveryButton;

@property (nonatomic, strong) UIStackView *accessoryList;
@property (nonatomic, strong) NSMutableArray<EAAccessory *> *detectedAccessories;

@property (nonatomic, strong) NSLayoutConstraint *sidebarWidthConstraint;

@end

@implementation ViewController

#pragma mark - Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];

    self.detectedAccessories = [NSMutableArray array];

    self.view.backgroundColor = [UIColor colorWithRed:0.94
                                                green:0.95
                                                 blue:0.97
                                                alpha:1.0];

    [self buildInterface];
    [self registerAccessoryNotifications];
    [self scanForAccessories];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self scanForAccessories];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Interface

- (void)buildInterface {
    self.sidebar = [[UIView alloc] init];
    self.sidebar.translatesAutoresizingMaskIntoConstraints = NO;
    self.sidebar.backgroundColor =
        [UIColor colorWithRed:0.91 green:0.92 blue:0.94 alpha:1.0];

    [self.view addSubview:self.sidebar];

    self.toolbar = [[UIView alloc] init];
    self.toolbar.translatesAutoresizingMaskIntoConstraints = NO;
    self.toolbar.backgroundColor = UIColor.whiteColor;
    [self.view addSubview:self.toolbar];

    self.contentView = [[UIView alloc] init];
    self.contentView.translatesAutoresizingMaskIntoConstraints = NO;
    self.contentView.backgroundColor =
        [UIColor colorWithRed:0.97 green:0.97 blue:0.98 alpha:1.0];
    [self.view addSubview:self.contentView];

    self.sidebarWidthConstraint =
        [self.sidebar.widthAnchor constraintEqualToConstant:142.0];

    [NSLayoutConstraint activateConstraints:@[
        [self.sidebar.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [self.sidebar.topAnchor constraintEqualToAnchor:self.view.topAnchor],
        [self.sidebar.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor],
        self.sidebarWidthConstraint,

        [self.toolbar.leadingAnchor constraintEqualToAnchor:self.sidebar.trailingAnchor],
        [self.toolbar.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [self.toolbar.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor],
        [self.toolbar.heightAnchor constraintEqualToConstant:58.0],

        [self.contentView.leadingAnchor constraintEqualToAnchor:self.sidebar.trailingAnchor],
        [self.contentView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [self.contentView.topAnchor constraintEqualToAnchor:self.toolbar.bottomAnchor],
        [self.contentView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor]
    ]];

    [self buildSidebar];
    [self buildToolbar];
    [self buildMainContent];
}

- (UILabel *)labelWithText:(NSString *)text
                      size:(CGFloat)size
                     color:(UIColor *)color
                    weight:(UIFontWeight)weight {
    UILabel *label = [[UILabel alloc] init];
    label.translatesAutoresizingMaskIntoConstraints = NO;
    label.text = text;
    label.font = [UIFont systemFontOfSize:size weight:weight];
    label.textColor = color;
    label.numberOfLines = 0;
    return label;
}

- (UIView *)makeCard {
    UIView *card = [[UIView alloc] init];
    card.translatesAutoresizingMaskIntoConstraints = NO;
    card.backgroundColor = UIColor.whiteColor;
    card.layer.cornerRadius = 12.0;
    card.layer.borderWidth = 1.0;
    card.layer.borderColor =
        [UIColor colorWithWhite:0.86 alpha:1.0].CGColor;
    return card;
}

#pragma mark - Sidebar

- (void)buildSidebar {
    UILabel *appLabel =
        [self labelWithText:@"BlackRestore"
                       size:17
                      color:[UIColor colorWithRed:0.16 green:0.17 blue:0.20 alpha:1]
                     weight:UIFontWeightBold];

    [self.sidebar addSubview:appLabel];

    UILabel *sectionLabel =
        [self labelWithText:@"LOCATIONS"
                       size:10
                      color:[UIColor secondaryLabelColor]
                     weight:UIFontWeightBold];

    [self.sidebar addSubview:sectionLabel];

    UIButton *devicesButton =
        [self sidebarButtonWithTitle:@"Devices"
                                icon:@"iphone"
                            selected:YES];

    [self.sidebar addSubview:devicesButton];

    UIButton *recoveryButton =
        [self sidebarButtonWithTitle:@"Recovery"
                                icon:@"arrow.clockwise"
                            selected:NO];

    [self.sidebar addSubview:recoveryButton];

    UIButton *activityButton =
        [self sidebarButtonWithTitle:@"Activity"
                                icon:@"clock"
                            selected:NO];

    [self.sidebar addSubview:activityButton];

    UILabel *footer =
        [self labelWithText:@"DEVICE UTILITY"
                       size:9
                      color:[UIColor secondaryLabelColor]
                     weight:UIFontWeightSemibold];

    [self.sidebar addSubview:footer];

    [NSLayoutConstraint activateConstraints:@[
        [appLabel.topAnchor constraintEqualToAnchor:self.sidebar.safeAreaLayoutGuide.topAnchor constant:18],
        [appLabel.leadingAnchor constraintEqualToAnchor:self.sidebar.leadingAnchor constant:13],
        [appLabel.trailingAnchor constraintEqualToAnchor:self.sidebar.trailingAnchor constant:-6],

        [sectionLabel.topAnchor constraintEqualToAnchor:appLabel.bottomAnchor constant:35],
        [sectionLabel.leadingAnchor constraintEqualToAnchor:self.sidebar.leadingAnchor constant:13],

        [devicesButton.topAnchor constraintEqualToAnchor:sectionLabel.bottomAnchor constant:12],
        [devicesButton.leadingAnchor constraintEqualToAnchor:self.sidebar.leadingAnchor constant:7],
        [devicesButton.trailingAnchor constraintEqualToAnchor:self.sidebar.trailingAnchor constant:-7],
        [devicesButton.heightAnchor constraintEqualToConstant:36],

        [recoveryButton.topAnchor constraintEqualToAnchor:devicesButton.bottomAnchor constant:5],
        [recoveryButton.leadingAnchor constraintEqualToAnchor:devicesButton.leadingAnchor],
        [recoveryButton.trailingAnchor constraintEqualToAnchor:devicesButton.trailingAnchor],
        [recoveryButton.heightAnchor constraintEqualToConstant:36],

        [activityButton.topAnchor constraintEqualToAnchor:recoveryButton.bottomAnchor constant:5],
        [activityButton.leadingAnchor constraintEqualToAnchor:devicesButton.leadingAnchor],
        [activityButton.trailingAnchor constraintEqualToAnchor:devicesButton.trailingAnchor],
        [activityButton.heightAnchor constraintEqualToConstant:36],

        [footer.leadingAnchor constraintEqualToAnchor:self.sidebar.leadingAnchor constant:13],
        [footer.bottomAnchor constraintEqualToAnchor:self.sidebar.safeAreaLayoutGuide.bottomAnchor constant:-18]
    ]];
}

- (UIButton *)sidebarButtonWithTitle:(NSString *)title
                                icon:(NSString *)icon
                            selected:(BOOL)selected {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    button.translatesAutoresizingMaskIntoConstraints = NO;

    UIImageSymbolConfiguration *configuration =
        [UIImageSymbolConfiguration configurationWithPointSize:14
                                                        weight:UIImageSymbolWeightMedium];

    UIImage *image = [UIImage systemImageNamed:icon
                         withConfiguration:configuration];

    [button setImage:image forState:UIControlStateNormal];
    [button setTitle:[@"  " stringByAppendingString:title]
            forState:UIControlStateNormal];

    button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    button.titleLabel.font = [UIFont systemFontOfSize:12 weight:UIFontWeightMedium];
    button.layer.cornerRadius = 7.0;

    UIColor *textColor = selected
        ? [UIColor colorWithRed:0.13 green:0.35 blue:0.76 alpha:1]
        : [UIColor colorWithRed:0.25 green:0.26 blue:0.29 alpha:1];

    [button setTitleColor:textColor forState:UIControlStateNormal];
    button.tintColor = textColor;

    if (selected) {
        button.backgroundColor =
            [UIColor colorWithRed:0.82 green:0.87 blue:0.96 alpha:1.0];
    }

    return button;
}

#pragma mark - Toolbar

- (void)buildToolbar {
    self.titleLabel =
        [self labelWithText:@"Devices"
                       size:19
                      color:[UIColor colorWithRed:0.12 green:0.13 blue:0.15 alpha:1]
                     weight:UIFontWeightSemibold];

    [self.toolbar addSubview:self.titleLabel];

    self.connectionLabel =
        [self labelWithText:@"Not connected"
                       size:11
                      color:UIColor.secondaryLabelColor
                     weight:UIFontWeightRegular];

    [self.toolbar addSubview:self.connectionLabel];

    self.statusIndicator = [[UIView alloc] init];
    self.statusIndicator.translatesAutoresizingMaskIntoConstraints = NO;
    self.statusIndicator.backgroundColor = UIColor.systemGrayColor;
    self.statusIndicator.layer.cornerRadius = 4.0;
    [self.toolbar addSubview:self.statusIndicator];

    self.scanButton = [UIButton buttonWithType:UIButtonTypeSystem];
    self.scanButton.translatesAutoresizingMaskIntoConstraints = NO;
    self.scanButton.backgroundColor =
        [UIColor colorWithRed:0.14 green:0.39 blue:0.83 alpha:1];
    self.scanButton.layer.cornerRadius = 7.0;
    self.scanButton.titleLabel.font =
        [UIFont systemFontOfSize:12 weight:UIFontWeightSemibold];
    [self.scanButton setTitle:@"Scan" forState:UIControlStateNormal];
    [self.scanButton setTitleColor:UIColor.whiteColor
                          forState:UIControlStateNormal];
    [self.scanButton addTarget:self
                        action:@selector(scanButtonTapped)
              forControlEvents:UIControlEventTouchUpInside];

    [self.toolbar addSubview:self.scanButton];

    [NSLayoutConstraint activateConstraints:@[
        [self.titleLabel.leadingAnchor constraintEqualToAnchor:self.toolbar.leadingAnchor constant:18],
        [self.titleLabel.centerYAnchor constraintEqualToAnchor:self.toolbar.centerYAnchor],

        [self.statusIndicator.widthAnchor constraintEqualToConstant:8],
        [self.statusIndicator.heightAnchor constraintEqualToConstant:8],
        [self.statusIndicator.leadingAnchor constraintEqualToAnchor:self.titleLabel.trailingAnchor constant:12],
        [self.statusIndicator.centerYAnchor constraintEqualToAnchor:self.toolbar.centerYAnchor],

        [self.connectionLabel.leadingAnchor constraintEqualToAnchor:self.statusIndicator.trailingAnchor constant:6],
        [self.connectionLabel.centerYAnchor constraintEqualToAnchor:self.toolbar.centerYAnchor],

        [self.scanButton.trailingAnchor constraintEqualToAnchor:self.toolbar.trailingAnchor constant:-12],
        [self.scanButton.centerYAnchor constraintEqualToAnchor:self.toolbar.centerYAnchor],
        [self.scanButton.widthAnchor constraintEqualToConstant:58],
        [self.scanButton.heightAnchor constraintEqualToConstant:31]
    ]];
}

#pragma mark - Main Content

- (void)buildMainContent {
    UIScrollView *scrollView = [[UIScrollView alloc] init];
    scrollView.translatesAutoresizingMaskIntoConstraints = NO;
    scrollView.alwaysBounceVertical = YES;
    [self.contentView addSubview:scrollView];

    UIView *page = [[UIView alloc] init];
    page.translatesAutoresizingMaskIntoConstraints = NO;
    [scrollView addSubview:page];

    [NSLayoutConstraint activateConstraints:@[
        [scrollView.topAnchor constraintEqualToAnchor:self.contentView.topAnchor],
        [scrollView.leadingAnchor constraintEqualToAnchor:self.contentView.leadingAnchor],
        [scrollView.trailingAnchor constraintEqualToAnchor:self.contentView.trailingAnchor],
        [scrollView.bottomAnchor constraintEqualToAnchor:self.contentView.bottomAnchor],

        [page.topAnchor constraintEqualToAnchor:scrollView.contentLayoutGuide.topAnchor],
        [page.leadingAnchor constraintEqualToAnchor:scrollView.contentLayoutGuide.leadingAnchor],
        [page.trailingAnchor constraintEqualToAnchor:scrollView.contentLayoutGuide.trailingAnchor],
        [page.bottomAnchor constraintEqualToAnchor:scrollView.contentLayoutGuide.bottomAnchor],
        [page.widthAnchor constraintEqualToAnchor:scrollView.frameLayoutGuide.widthAnchor]
    ]];

    UILabel *heading =
        [self labelWithText:@"Connected Device"
                       size:23
                      color:[UIColor colorWithRed:0.12 green:0.13 blue:0.15 alpha:1]
                     weight:UIFontWeightBold];

    UILabel *subtitle =
        [self labelWithText:@"Connect a supported device or accessory to get started."
                       size:12
                      color:UIColor.secondaryLabelColor
                     weight:UIFontWeightRegular];

    [page addSubview:heading];
    [page addSubview:subtitle];

    UIView *deviceCard = [self makeCard];
    [page addSubview:deviceCard];

    self.deviceIconView = [[UIView alloc] init];
    self.deviceIconView.translatesAutoresizingMaskIntoConstraints = NO;
    self.deviceIconView.backgroundColor =
        [UIColor colorWithRed:0.92 green:0.94 blue:0.97 alpha:1];
    self.deviceIconView.layer.cornerRadius = 15;
    [deviceCard addSubview:self.deviceIconView];

    self.deviceIcon = [[UIImageView alloc] initWithImage:
                       [UIImage systemImageNamed:@"iphone"]];
    self.deviceIcon.translatesAutoresizingMaskIntoConstraints = NO;
    self.deviceIcon.contentMode = UIViewContentModeScaleAspectFit;
    self.deviceIcon.tintColor =
        [UIColor colorWithRed:0.31 green:0.34 blue:0.40 alpha:1];
    [self.deviceIconView addSubview:self.deviceIcon];

    self.deviceNameLabel =
        [self labelWithText:@"No device detected"
                       size:17
                      color:[UIColor labelColor]
                     weight:UIFontWeightSemibold];

    self.deviceDetailsLabel =
        [self labelWithText:@"Connect a supported accessory, then scan again."
                       size:12
                      color:UIColor.secondaryLabelColor
                     weight:UIFontWeightRegular];

    [deviceCard addSubview:self.deviceNameLabel];
    [deviceCard addSubview:self.deviceDetailsLabel];

    UIView *separator = [[UIView alloc] init];
    separator.translatesAutoresizingMaskIntoConstraints = NO;
    separator.backgroundColor = [UIColor colorWithWhite:0.91 alpha:1];
    [deviceCard addSubview:separator];

    self.lastScanLabel =
        [self labelWithText:@"Last scan: not yet scanned"
                       size:11
                      color:UIColor.secondaryLabelColor
                     weight:UIFontWeightRegular];

    [deviceCard addSubview:self.lastScanLabel];

    UILabel *detailsHeading =
        [self labelWithText:@"Device Information"
                       size:16
                      color:UIColor.labelColor
                     weight:UIFontWeightSemibold];

    [page addSubview:detailsHeading];

    UIView *detailsCard = [self makeCard];
    [page addSubview:detailsCard];

    UILabel *connectionKey =
        [self labelWithText:@"Connection"
                       size:12
                      color:UIColor.secondaryLabelColor
                     weight:UIFontWeightRegular];

    self.statusLabel =
        [self labelWithText:@"No supported accessory reported by iOS"
                       size:12
                      color:UIColor.labelColor
                     weight:UIFontWeightMedium];

    UILabel *protocolKey =
        [self labelWithText:@"Detection method"
                       size:12
                      color:UIColor.secondaryLabelColor
                     weight:UIFontWeightRegular];

    UILabel *protocolValue =
        [self labelWithText:@"Apple ExternalAccessory API"
                       size:12
                      color:UIColor.labelColor
                     weight:UIFontWeightMedium];

    UILabel *limitationKey =
        [self labelWithText:@"USB device access"
                       size:12
                      color:UIColor.secondaryLabelColor
                     weight:UIFontWeightRegular];

    UILabel *limitationValue =
        [self labelWithText:@"General iPhone / Recovery / DFU detection is unavailable to this jailed app."
                       size:12
                      color:UIColor.labelColor
                     weight:UIFontWeightMedium];

    [detailsCard addSubview:connectionKey];
    [detailsCard addSubview:self.statusLabel];
    [detailsCard addSubview:protocolKey];
    [detailsCard addSubview:protocolValue];
    [detailsCard addSubview:limitationKey];
    [detailsCard addSubview:limitationValue];

    UILabel *actionsHeading =
        [self labelWithText:@"Recovery & Restore"
                       size:16
                      color:UIColor.labelColor
                     weight:UIFontWeightSemibold];

    [page addSubview:actionsHeading];

    UIView *actionsCard = [self makeCard];
    [page addSubview:actionsCard];

    UILabel *actionsDescription =
        [self labelWithText:@"These controls are placeholders until a supported restoration mechanism is implemented."
                       size:12
                      color:UIColor.secondaryLabelColor
                     weight:UIFontWeightRegular];

    [actionsCard addSubview:actionsDescription];

    self.recoveryButton = [self actionButtonWithTitle:@"Enter Recovery"
                                                 icon:@"arrow.clockwise"];

    self.restoreButton = [self actionButtonWithTitle:@"Restore Device"
                                                icon:@"arrow.down.to.line"];

    self.recoveryButton.enabled = NO;
    self.restoreButton.enabled = NO;

    [actionsCard addSubview:self.recoveryButton];
    [actionsCard addSubview:self.restoreButton];

    self.accessoryList = [[UIStackView alloc] init];
    self.accessoryList.translatesAutoresizingMaskIntoConstraints = NO;
    self.accessoryList.axis = UILayoutConstraintAxisVertical;
    self.accessoryList.spacing = 7;
    [page addSubview:self.accessoryList];

    [NSLayoutConstraint activateConstraints:@[
        [heading.topAnchor constraintEqualToAnchor:page.topAnchor constant:22],
        [heading.leadingAnchor constraintEqualToAnchor:page.leadingAnchor constant:18],
        [heading.trailingAnchor constraintEqualToAnchor:page.trailingAnchor constant:-14],

        [subtitle.topAnchor constraintEqualToAnchor:heading.bottomAnchor constant:5],
        [subtitle.leadingAnchor constraintEqualToAnchor:heading.leadingAnchor],
        [subtitle.trailingAnchor constraintEqualToAnchor:page.trailingAnchor constant:-14],

        [deviceCard.topAnchor constraintEqualToAnchor:subtitle.bottomAnchor constant:19],
        [deviceCard.leadingAnchor constraintEqualToAnchor:page.leadingAnchor constant:14],
        [deviceCard.trailingAnchor constraintEqualToAnchor:page.trailingAnchor constant:-14],

        [self.deviceIconView.topAnchor constraintEqualToAnchor:deviceCard.topAnchor constant:17],
        [self.deviceIconView.leadingAnchor constraintEqualToAnchor:deviceCard.leadingAnchor constant:15],
        [self.deviceIconView.widthAnchor constraintEqualToConstant:56],
        [self.deviceIconView.heightAnchor constraintEqualToConstant:66],

        [self.deviceIcon.centerXAnchor constraintEqualToAnchor:self.deviceIconView.centerXAnchor],
        [self.deviceIcon.centerYAnchor constraintEqualToAnchor:self.deviceIconView.centerYAnchor],
        [self.deviceIcon.widthAnchor constraintEqualToConstant:28],
        [self.deviceIcon.heightAnchor constraintEqualToConstant:37],

        [self.deviceNameLabel.topAnchor constraintEqualToAnchor:self.deviceIconView.topAnchor constant:7],
        [self.deviceNameLabel.leadingAnchor constraintEqualToAnchor:self.deviceIconView.trailingAnchor constant:13],
        [self.deviceNameLabel.trailingAnchor constraintEqualToAnchor:deviceCard.trailingAnchor constant:-10],

        [self.deviceDetailsLabel.topAnchor constraintEqualToAnchor:self.deviceNameLabel.bottomAnchor constant:5],
        [self.deviceDetailsLabel.leadingAnchor constraintEqualToAnchor:self.deviceNameLabel.leadingAnchor],
        [self.deviceDetailsLabel.trailingAnchor constraintEqualToAnchor:self.deviceNameLabel.trailingAnchor],

        [separator.topAnchor constraintEqualToAnchor:self.deviceIconView.bottomAnchor constant:15],
        [separator.leadingAnchor constraintEqualToAnchor:deviceCard.leadingAnchor constant:15],
        [separator.trailingAnchor constraintEqualToAnchor:deviceCard.trailingAnchor constant:-15],
        [separator.heightAnchor constraintEqualToConstant:1],

        [self.lastScanLabel.topAnchor constraintEqualToAnchor:separator.bottomAnchor constant:11],
        [self.lastScanLabel.leadingAnchor constraintEqualToAnchor:separator.leadingAnchor],
        [self.lastScanLabel.trailingAnchor constraintEqualToAnchor:separator.trailingAnchor],
        [self.lastScanLabel.bottomAnchor constraintEqualToAnchor:deviceCard.bottomAnchor constant:-12],

        [detailsHeading.topAnchor constraintEqualToAnchor:deviceCard.bottomAnchor constant:22],
        [detailsHeading.leadingAnchor constraintEqualToAnchor:heading.leadingAnchor],
        [detailsHeading.trailingAnchor constraintEqualToAnchor:heading.trailingAnchor],

        [detailsCard.topAnchor constraintEqualToAnchor:detailsHeading.bottomAnchor constant:10],
        [detailsCard.leadingAnchor constraintEqualToAnchor:deviceCard.leadingAnchor],
        [detailsCard.trailingAnchor constraintEqualToAnchor:deviceCard.trailingAnchor],

        [connectionKey.topAnchor constraintEqualToAnchor:detailsCard.topAnchor constant:15],
        [connectionKey.leadingAnchor constraintEqualToAnchor:detailsCard.leadingAnchor constant:14],
        [connectionKey.widthAnchor constraintEqualToConstant:105],

        [self.statusLabel.leadingAnchor constraintEqualToAnchor:connectionKey.trailingAnchor constant:5],
        [self.statusLabel.topAnchor constraintEqualToAnchor:connectionKey.topAnchor],
        [self.statusLabel.trailingAnchor constraintEqualToAnchor:detailsCard.trailingAnchor constant:-12],

        [protocolKey.topAnchor constraintEqualToAnchor:connectionKey.bottomAnchor constant:14],
        [protocolKey.leadingAnchor constraintEqualToAnchor:connectionKey.leadingAnchor],
        [protocolKey.widthAnchor constraintEqualToAnchor:connectionKey.widthAnchor],

        [protocolValue.topAnchor constraintEqualToAnchor:protocolKey.topAnchor],
        [protocolValue.leadingAnchor constraintEqualToAnchor:protocolKey.trailingAnchor constant:5],
        [protocolValue.trailingAnchor constraintEqualToAnchor:self.statusLabel.trailingAnchor],

        [limitationKey.topAnchor constraintEqualToAnchor:protocolKey.bottomAnchor constant:14],
        [limitationKey.leadingAnchor constraintEqualToAnchor:connectionKey.leadingAnchor],
        [limitationKey.widthAnchor constraintEqualToAnchor:connectionKey.widthAnchor],

        [limitationValue.topAnchor constraintEqualToAnchor:limitationKey.topAnchor],
        [limitationValue.leadingAnchor constraintEqualToAnchor:limitationKey.trailingAnchor constant:5],
        [limitationValue.trailingAnchor constraintEqualToAnchor:self.statusLabel.trailingAnchor],
        [limitationValue.bottomAnchor constraintEqualToAnchor:detailsCard.bottomAnchor constant:-15],

        [actionsHeading.topAnchor constraintEqualToAnchor:detailsCard.bottomAnchor constant:22],
        [actionsHeading.leadingAnchor constraintEqualToAnchor:heading.leadingAnchor],
        [actionsHeading.trailingAnchor constraintEqualToAnchor:heading.trailingAnchor],

        [actionsCard.topAnchor constraintEqualToAnchor:actionsHeading.bottomAnchor constant:10],
        [actionsCard.leadingAnchor constraintEqualToAnchor:deviceCard.leadingAnchor],
        [actionsCard.trailingAnchor constraintEqualToAnchor:deviceCard.trailingAnchor],

        [actionsDescription.topAnchor constraintEqualToAnchor:actionsCard.topAnchor constant:14],
        [actionsDescription.leadingAnchor constraintEqualToAnchor:actionsCard.leadingAnchor constant:14],
        [actionsDescription.trailingAnchor constraintEqualToAnchor:actionsCard.trailingAnchor constant:-14],

        [self.recoveryButton.topAnchor constraintEqualToAnchor:actionsDescription.bottomAnchor constant:13],
        [self.recoveryButton.leadingAnchor constraintEqualToAnchor:actionsCard.leadingAnchor constant:14],
        [self.recoveryButton.trailingAnchor constraintEqualToAnchor:actionsCard.trailingAnchor constant:-14],
        [self.recoveryButton.heightAnchor constraintEqualToConstant:38],

        [self.restoreButton.topAnchor constraintEqualToAnchor:self.recoveryButton.bottomAnchor constant:8],
        [self.restoreButton.leadingAnchor constraintEqualToAnchor:self.recoveryButton.leadingAnchor],
        [self.restoreButton.trailingAnchor constraintEqualToAnchor:self.recoveryButton.trailingAnchor],
        [self.restoreButton.heightAnchor constraintEqualToConstant:38],
        [self.restoreButton.bottomAnchor constraintEqualToAnchor:actionsCard.bottomAnchor constant:-14],

        [self.accessoryList.topAnchor constraintEqualToAnchor:actionsCard.bottomAnchor constant:12],
        [self.accessoryList.leadingAnchor constraintEqualToAnchor:deviceCard.leadingAnchor],
        [self.accessoryList.trailingAnchor constraintEqualToAnchor:deviceCard.trailingAnchor],
        [self.accessoryList.bottomAnchor constraintEqualToAnchor:page.bottomAnchor constant:-25]
    ]];
}

- (UIButton *)actionButtonWithTitle:(NSString *)title icon:(NSString *)icon {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    button.translatesAutoresizingMaskIntoConstraints = NO;

    UIImageSymbolConfiguration *configuration =
        [UIImageSymbolConfiguration configurationWithPointSize:13
                                                        weight:UIImageSymbolWeightMedium];

    [button setImage:[UIImage systemImageNamed:icon
                             withConfiguration:configuration]
            forState:UIControlStateNormal];

    [button setTitle:[@"  " stringByAppendingString:title]
            forState:UIControlStateNormal];

    button.titleLabel.font =
        [UIFont systemFontOfSize:12 weight:UIFontWeightSemibold];

    button.layer.cornerRadius = 7.0;
    button.layer.borderWidth = 1.0;
    button.layer.borderColor =
        [UIColor colorWithWhite:0.83 alpha:1.0].CGColor;

    button.backgroundColor =
        [UIColor colorWithRed:0.97 green:0.97 blue:0.98 alpha:1.0];

    [button setTitleColor:UIColor.secondaryLabelColor
                 forState:UIControlStateNormal];

    button.tintColor = UIColor.secondaryLabelColor;

    return button;
}

#pragma mark - Accessory Detection

- (void)registerAccessoryNotifications {
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];

    [center addObserver:self
               selector:@selector(accessoryConnected:)
                   name:EAAccessoryDidConnectNotification
                 object:nil];

    [center addObserver:self
               selector:@selector(accessoryDisconnected:)
                   name:EAAccessoryDidDisconnectNotification
                 object:nil];

    [[EAAccessoryManager sharedAccessoryManager]
        registerForLocalNotifications];
}

- (void)scanButtonTapped {
    [self scanForAccessories];
}

- (void)scanForAccessories {
    EAAccessoryManager *manager = [EAAccessoryManager sharedAccessoryManager];

    NSArray<EAAccessory *> *accessories = manager.connectedAccessories;

    [self.detectedAccessories removeAllObjects];
    [self.detectedAccessories addObjectsFromArray:accessories];

    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateStyle = NSDateFormatterNoStyle;
    formatter.timeStyle = NSDateFormatterShortStyle;

    self.lastScanLabel.text =
        [NSString stringWithFormat:@"Last scan: %@",
         [formatter stringFromDate:[NSDate date]]];

    [self updateDetectionInterface];
}

- (void)accessoryConnected:(NSNotification *)notification {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self scanForAccessories];
    });
}

- (void)accessoryDisconnected:(NSNotification *)notification {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self scanForAccessories];
    });
}

- (void)updateDetectionInterface {
    for (UIView *view in self.accessoryList.arrangedSubviews) {
        [self.accessoryList removeArrangedSubview:view];
        [view removeFromSuperview];
    }

    if (self.detectedAccessories.count == 0) {
        self.connectionLabel.text = @"Not connected";
        self.statusIndicator.backgroundColor = UIColor.systemGrayColor;

        self.deviceNameLabel.text = @"No supported accessory detected";
        self.deviceDetailsLabel.text =
            @"iOS did not report an accessory through ExternalAccessory.";

        self.statusLabel.text = @"No supported accessory reported";
        self.deviceIcon.image = [UIImage systemImageNamed:@"iphone"];
        self.deviceIcon.tintColor = UIColor.secondaryLabelColor;

        UILabel *explanation =
            [self labelWithText:
             @"Important: connecting another iPhone by USB does not make it an ExternalAccessory device. This scan cannot detect arbitrary iPhones, Recovery Mode, or DFU Mode."
                            size:12
                           color:UIColor.secondaryLabelColor
                          weight:UIFontWeightRegular];

        explanation.backgroundColor =
            [UIColor colorWithRed:0.96 green:0.96 blue:0.97 alpha:1];

        explanation.layer.cornerRadius = 8;
        explanation.layer.masksToBounds = YES;
        explanation.layoutMargins = UIEdgeInsetsMake(10, 10, 10, 10);

        [self.accessoryList addArrangedSubview:explanation];

        [NSLayoutConstraint activateConstraints:@[
            [explanation.heightAnchor constraintGreaterThanOrEqualToConstant:66]
        ]];

        return;
    }

    self.connectionLabel.text =
        [NSString stringWithFormat:@"%lu accessory%@",
         (unsigned long)self.detectedAccessories.count,
         self.detectedAccessories.count == 1 ? @"" : @"ies"];

    self.statusIndicator.backgroundColor = UIColor.systemGreenColor;
    self.deviceNameLabel.text = @"Supported accessory detected";
    self.deviceDetailsLabel.text =
        @"iOS reported the following connected accessory.";

    self.statusLabel.text = @"Accessory detected";
    self.deviceIcon.image = [UIImage systemImageNamed:@"cable.connector"];
    self.deviceIcon.tintColor = UIColor.systemGreenColor;

    for (EAAccessory *accessory in self.detectedAccessories) {
        UIView *row = [self makeCard];

        UILabel *name =
            [self labelWithText:accessory.name ?: @"Unnamed accessory"
                           size:13
                          color:UIColor.labelColor
                         weight:UIFontWeightSemibold];

        UILabel *details =
            [self labelWithText:
             [NSString stringWithFormat:@"%@ · %@",
              accessory.manufacturer ?: @"Unknown manufacturer",
              accessory.modelNumber ?: @"Unknown model"]
                           size:11
                          color:UIColor.secondaryLabelColor
                         weight:UIFontWeightRegular];

        [row addSubview:name];
        [row addSubview:details];

        [NSLayoutConstraint activateConstraints:@[
            [row.heightAnchor constraintGreaterThanOrEqualToConstant:66],

            [name.topAnchor constraintEqualToAnchor:row.topAnchor constant:12],
            [name.leadingAnchor constraintEqualToAnchor:row.leadingAnchor constant:12],
            [name.trailingAnchor constraintEqualToAnchor:row.trailingAnchor constant:-12],

            [details.topAnchor constraintEqualToAnchor:name.bottomAnchor constant:5],
            [details.leadingAnchor constraintEqualToAnchor:name.leadingAnchor],
            [details.trailingAnchor constraintEqualToAnchor:name.trailingAnchor],
            [details.bottomAnchor constraintLessThanOrEqualToAnchor:row.bottomAnchor constant:-10]
        ]];

        [self.accessoryList addArrangedSubview:row];
    }
}

@end
