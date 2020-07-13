#import "CheckupWaveView.h"

static const CGFloat kDefaultFrequency          = 1.5f;
static const CGFloat kDefaultAmplitude          = 1.0f;
static const CGFloat kDefaultIdleAmplitude      = 0.1;
static const CGFloat kDefaultNumberOfWaves      = 5.0f;
static const CGFloat kDefaultPhaseShift         = -0.15f;
static const CGFloat kDefaultDensity            = 5.0f;
static const CGFloat kDefaultPrimaryLineWidth   = 3.0f;
static const CGFloat kDefaultSecondaryLineWidth = 1.0f;

@interface CheckupWaveView ()

@property (nonatomic, assign) CGFloat phase;
@property (nonatomic, assign) CGFloat amplitude;

@end

@implementation CheckupWaveView

- (instancetype)initWithFrame:(CGRect)frame
{
	if (self = [super initWithFrame:frame]) {
		[self setup];
	}
	
	return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
	if (self = [super initWithCoder:aDecoder]) {
		[self setup];
	}
	return self;
}

- (void)setup
{
	self.waveColor = [UIColor whiteColor];
	self.frequency = kDefaultFrequency;
	self.amplitude = kDefaultAmplitude;
	self.idleAmplitude = kDefaultIdleAmplitude;
	self.dampingFactor = 0.8;
	self.numberOfWaves = kDefaultNumberOfWaves;
	self.phaseShift = kDefaultPhaseShift;
	self.density = kDefaultDensity;
	self.primaryWaveLineWidth = kDefaultPrimaryLineWidth;
	self.secondaryWaveLineWidth = kDefaultSecondaryLineWidth;
	self.active = YES;
}

- (void)start {
	//NSLog(@"The value of bool is inside = %d", self.active);
	// Create a recorder instance, recording to /dev/null to trash the data immediately
	NSURL *url = [NSURL fileURLWithPath:@"/dev/null"];
	NSError *error = nil;
	self.recorder = [[AVAudioRecorder alloc] initWithURL:url settings:@{
        AVSampleRateKey: @44100,
		AVFormatIDKey: @(kAudioFormatAppleLossless),
		AVNumberOfChannelsKey: @1,
		AVEncoderAudioQualityKey: @(AVAudioQualityMax)
	} error:&error];
		
	if (!self.recorder || error) {
		NSLog(@"WARNING: %@ could not create a recorder instance (%@).", self, error.localizedDescription);
	} else {
		[self.recorder prepareToRecord];
		self.recorder.meteringEnabled = YES;
		[self.recorder record];
	}
	[self setNeedsDisplay];
}

- (void)stop {
	//NSLog(@"The value of bool is inside = %d", self.active);
	[self.recorder stop];
	self.amplitude = 0;
	[self setNeedsDisplay];
}

- (void)recorderDidRecord {
	//NSLog(@"The value of bool is inside = %d", self.active);
	[self.recorder updateMeters];

	float soundLevel = [self normalizedPowerLevelFromDecibels:[self.recorder averagePowerForChannel:0]];
	
	self.phase += self.phaseShift;
	self.amplitude = fmax(fmin(soundLevel, 1.0), self.idleAmplitude);
	
	[self setNeedsDisplay];
}

- (CGFloat)normalizedPowerLevelFromDecibels:(CGFloat)decibels {
	//NSLog(@"Avg. Power: %f", decibels);

    if (decibels < -60.0f || decibels == 0.0f) {
        return 0.05f;
    }
    
    return powf((powf(10.0f, 0.05f * decibels) - powf(10.0f, 0.05f * -60.0f)) * (1.0f / (1.0f - powf(10.0f, 0.05f * -60.0f))), 1.0f / 2.0f);
}

- (void)drawRect:(CGRect)rect
{
	CGContextRef context = UIGraphicsGetCurrentContext();
	CGContextClearRect(context, self.bounds);
	
	[self.backgroundColor set];
	CGContextFillRect(context, rect);
	
	// We draw multiple sinus waves, with equal phases but altered amplitudes, multiplied by a parable function.
	for (int i = 0; i < self.numberOfWaves; i++) {
		CGFloat strokeLineWidth = (i == 0 ? self.primaryWaveLineWidth : self.secondaryWaveLineWidth);
		CGContextSetLineWidth(context, strokeLineWidth);
		
		CGFloat halfHeight = CGRectGetHeight(self.bounds) / 2.0f;
		CGFloat width = CGRectGetWidth(self.bounds);
		CGFloat mid = width / 2.0f;
		
		const CGFloat maxAmplitude = halfHeight - (strokeLineWidth * 2);
		
		CGFloat progress = 1.0f - (CGFloat)i / self.numberOfWaves;
		CGFloat normedAmplitude = (1.5f * progress - 0.5f) * self.amplitude;
		
		CGFloat multiplier = MIN(1.0f, (progress / 3.0f * 2.0f) + (1.0f / 3.0f));
		[[self.waveColor colorWithAlphaComponent:multiplier * CGColorGetAlpha(self.waveColor.CGColor)] set];
		
		for (CGFloat x = 0; x < (width + self.density); x += self.density) {
			// We use a parable to scale the sinus wave, that has its peak in the middle of the view.
			CGFloat scaling = -pow(1 / mid * (x - mid), 2) + 1;
			
			CGFloat y = scaling * maxAmplitude * normedAmplitude * sinf(2 * M_PI *(x / width) * self.frequency + self.phase) + halfHeight;
			
			if (x == 0) {
				CGContextMoveToPoint(context, x, y);
			} else {
				CGContextAddLineToPoint(context, x, y);
			}
		}
		
		CGContextStrokePath(context);
	}
}

@end
