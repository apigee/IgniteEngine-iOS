//
//  IXSpeech.m
//  Ignite Engine
//
//  Created by Robert Walsh on 7/25/14.
//
/****************************************************************************
 The MIT License (MIT)
 Copyright (c) 2015 Apigee Corporation
 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:
 The above copyright notice and this permission notice shall be included in
 all copies or substantial portions of the Software.
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 THE SOFTWARE.
 ****************************************************************************/
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
    
    _utteranceSentences = [[[self attributeContainer] getCommaSeparatedArrayOfValuesForAttribute:kIXUtteranceSentences defaultValue:nil] mutableCopy];
    
    [self speakUtteranceForSentencesArray];
}

-(void)applyFunction:(NSString *)functionName withParameters:(IXAttributeContainer *)parameterContainer
{
    if( [functionName isEqualToString:kIXStartUtterance] )
    {
        if (_utterance.speechString.length > 0) {
            [[self speechSynthesizer] speakUtterance:_utterance];
        }
    }
    else if( [functionName isEqualToString:kIXQueueUtterance] )
    {
        [_utteranceSentences addObjectsFromArray:[parameterContainer getCommaSeparatedArrayOfValuesForAttribute:kIXUtteranceSentences defaultValue:nil]];
    }
    else if( [functionName isEqualToString:kIXContinue] )
    {
        [[self speechSynthesizer] continueSpeaking];
    }
    else if( [functionName isEqualToString:kIXPause] || [functionName isEqualToString:kIXStop] )
    {
        AVSpeechBoundary speechBoundary = AVSpeechBoundaryImmediate;
        NSString* boundaryString = [parameterContainer getStringValueForAttribute:kIXBoundary defaultValue:nil];
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
            [_utterance setRate:[[self attributeContainer] getFloatValueForAttribute:kIXUtteranceRate defaultValue:AVSpeechUtteranceDefaultSpeechRate]];
            [_utterance setPitchMultiplier:[[self attributeContainer] getFloatValueForAttribute:kIXUtterancePitch defaultValue:1.0f]];
            [_utterance setVolume:[[self attributeContainer] getFloatValueForAttribute:kIXUtteranceVolume defaultValue:1.0f]];
            [_utterance setPreUtteranceDelay:[[self attributeContainer] getFloatValueForAttribute:kIXUtteranceDelayStart defaultValue:0.0f]];
            [_utterance setPostUtteranceDelay:[[self attributeContainer] getFloatValueForAttribute:kIXUtteranceDelayEnd defaultValue:0.0f]];
        }
        [_utteranceSentences removeObjectAtIndex:idx];
    }];
}

@end
