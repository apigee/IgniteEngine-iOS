//
//  IXSpeech.m
//  Ignite Engine
//
//  Created by Robert Walsh on 7/25/14.
//  Copyright (c) 2015 Apigee. All rights reserved.
//

#import "IXTextToSpeech.h"

@import AVFoundation.AVSpeechSynthesis;

// IXSpeech Functions
IX_STATIC_CONST_STRING kIXQueueUtterance = @"queue"; // Adds string to queue
IX_STATIC_CONST_STRING kIXStartUtterance = @"start"; // Starts speaking
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

@interface IXTextToSpeech () <AVSpeechSynthesizerDelegate>

@property (nonatomic,strong) AVSpeechSynthesizer* speechSynthesizer;
@property (nonatomic,strong) AVSpeechUtterance* utterance;
@property (nonatomic,strong) NSMutableArray* utteranceSentences;

@end

@implementation IXTextToSpeech

-(void)buildView
{
    _speechSynthesizer = [[AVSpeechSynthesizer alloc] init];
    [_speechSynthesizer setDelegate:self];
}

-(void)applySettings
{
    [super applySettings];
    
    _utteranceSentences = [[[self propertyContainer] getCommaSeperatedArrayListValue:kIXUtteranceSentences defaultValue:nil] mutableCopy];
    
    [self speakUtteranceForSentencesArray];
}

-(void)applyFunction:(NSString *)functionName withParameters:(IXPropertyContainer *)parameterContainer
{
    if( [functionName isEqualToString:kIXStartUtterance] )
    {
        if (_utterance.speechString.length > 0) {
            [[self speechSynthesizer] speakUtterance:_utterance];
        }
    }
    else if( [functionName isEqualToString:kIXQueueUtterance] )
    {
        [_utteranceSentences addObjectsFromArray:[parameterContainer getCommaSeperatedArrayListValue:kIXUtteranceSentences defaultValue:nil]];
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


- (void)speechSynthesizer:(AVSpeechSynthesizer *)synthesizer didFinishSpeechUtterance:(AVSpeechUtterance *)utterance {
    if (_utteranceSentences.count > 0) {
        [self speakUtteranceForSentencesArray];
    }
}

- (void)speakUtteranceForSentencesArray {
    
    [_utteranceSentences enumerateObjectsUsingBlock:^(NSString* utteranceToSpeak, NSUInteger idx, BOOL *stop) {
        if( [utteranceToSpeak length] > 0 )
        {
            _utterance = [[AVSpeechUtterance alloc] initWithString:utteranceToSpeak];
            [_utterance setRate:[[self propertyContainer] getFloatPropertyValue:kIXUtteranceRate defaultValue:AVSpeechUtteranceDefaultSpeechRate]];
            [_utterance setPitchMultiplier:[[self propertyContainer] getFloatPropertyValue:kIXUtterancePitch defaultValue:1.0f]];
            [_utterance setVolume:[[self propertyContainer] getFloatPropertyValue:kIXUtteranceVolume defaultValue:1.0f]];
            [_utterance setPreUtteranceDelay:[[self propertyContainer] getFloatPropertyValue:kIXUtteranceDelayStart defaultValue:0.0f]];
            [_utterance setPostUtteranceDelay:[[self propertyContainer] getFloatPropertyValue:kIXUtteranceDelayEnd defaultValue:0.0f]];
        }
        [_utteranceSentences removeObjectAtIndex:idx];
    }];
}

@end
