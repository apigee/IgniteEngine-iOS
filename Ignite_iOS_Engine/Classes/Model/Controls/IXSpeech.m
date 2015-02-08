//
//  IXSpeech.m
//  Ignite_iOS_Engine
//
//  Created by Robert Walsh on 7/25/14.
//  Copyright (c) 2014 Ignite. All rights reserved.
//

#import "IXSpeech.h"

@import AVFoundation.AVSpeechSynthesis;

// IXSpeech Functions
IX_STATIC_CONST_STRING kIXQueueUtterance = @"queue";
IX_STATIC_CONST_STRING kIXPause = @"pause"; // Pauses so it can be continued.
IX_STATIC_CONST_STRING kIXContinue = @"continue"; // Continues if paused.
IX_STATIC_CONST_STRING kIXStop = @"stop"; // Stops and clears the utterance queue.

// kIXStart Function Attributes
IX_STATIC_CONST_STRING kIXUtteranceSentences = @"sentences"; // Array of sentences.
IX_STATIC_CONST_STRING kIXUtteranceRate = @"rate"; // Between 0.0 and 1.0.  Default is 0.5
IX_STATIC_CONST_STRING kIXUtterancePitch = @"pitch"; // Between 0.5 and 2.0. Default is 1.0
IX_STATIC_CONST_STRING kIXUtteranceVolume = @"volume"; // Between 0.0 and 1.0. Default is 1.0
IX_STATIC_CONST_STRING kIXUtteranceDelayStart = @"delayStart"; // Default is 0.0
IX_STATIC_CONST_STRING kIXUtteranceDelayEnd = @"delayEnd"; // Default is 0.0

// kIXPause and kIXStop Function Attributes
IX_STATIC_CONST_STRING kIXBoundary = @"boundary"; // Default is kIXBoundaryImmediate.
IX_STATIC_CONST_STRING kIXBoundaryImmediate = @"immediate";
IX_STATIC_CONST_STRING kIXBoundaryWord = @"word";

@interface IXSpeech () <AVSpeechSynthesizerDelegate>

@property (nonatomic,strong) AVSpeechSynthesizer* speechSynthesizer;

@end

@implementation IXSpeech

-(void)buildView
{
    _speechSynthesizer = [[AVSpeechSynthesizer alloc] init];
    [_speechSynthesizer setDelegate:self];
}

-(void)applySettings
{
    [super applySettings];
}

-(void)applyFunction:(NSString *)functionName withParameters:(IXPropertyContainer *)parameterContainer
{
    if( [functionName isEqualToString:kIXQueueUtterance] )
    {
        NSArray* utteranceSentences = [parameterContainer getCommaSeperatedArrayListValue:kIXUtteranceSentences defaultValue:nil];
        for( NSString* utteranceToSpeak in utteranceSentences )
        {
            if( [utteranceToSpeak length] > 0 )
            {
                AVSpeechUtterance* utterance = [[AVSpeechUtterance alloc] initWithString:utteranceToSpeak];
                [utterance setRate:[parameterContainer getFloatPropertyValue:kIXUtteranceRate defaultValue:AVSpeechUtteranceDefaultSpeechRate]];
                [utterance setPitchMultiplier:[parameterContainer getFloatPropertyValue:kIXUtterancePitch defaultValue:1.0f]];
                [utterance setVolume:[parameterContainer getFloatPropertyValue:kIXUtteranceVolume defaultValue:1.0f]];
                [utterance setPreUtteranceDelay:[parameterContainer getFloatPropertyValue:kIXUtteranceDelayStart defaultValue:0.0f]];
                [utterance setPostUtteranceDelay:[parameterContainer getFloatPropertyValue:kIXUtteranceDelayEnd defaultValue:0.0f]];
                [[self speechSynthesizer] speakUtterance:utterance];
            }
        }
    }
    else if( [functionName isEqualToString:kIXContinue] )
    {
        [[self speechSynthesizer] continueSpeaking];
    }
    else if( [functionName isEqualToString:kIXPause] || [functionName isEqualToString:kIXStop] )
    {
        AVSpeechBoundary speechBoundary = AVSpeechBoundaryImmediate;
        NSString* boundaryString = [parameterContainer getStringPropertyValue:kIXBoundary defaultValue:nil];
        if( [boundaryString isEqualToString:kIXBoundaryWord] ) {
            speechBoundary = AVSpeechBoundaryWord;
        }

        if( [functionName isEqualToString:kIXPause] ) {
            [[self speechSynthesizer] pauseSpeakingAtBoundary:speechBoundary];
        } else {
            [[self speechSynthesizer] stopSpeakingAtBoundary:speechBoundary];
        }
    }
    else
    {
        [super applyFunction:functionName withParameters:parameterContainer];
    }
}

@end
