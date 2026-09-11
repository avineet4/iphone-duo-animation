//
//  DuoFold.swift
//  iphone-duo-animation
//
//  Created by Avineet Singh on 11/9/26.
//

#include <metal_stdlib>
#include <SwiftUI/SwiftUI.h>
using namespace metal;

constant int kMaxTaps = 32;
constant float kGoldenAngle = 2.39996322972865332;
constant float kTwoPi = 6.28318530717958648;

static float rand2(float2 p) {
    return fract(sin(dot(p, float2(12.9898, 78.233))) * 43758.5453);
}

static half4 toOpaque(half4 premul) {
    return half4(premul.rgb, 1.0h);
}

[[ stitchable ]] half4 duoFold(
    float2 position,
    SwiftUI::Layer layer,
    float4 bounds,
    float tiltAngle,
    float eyeDistance,
    float blurSpread,
    float dimRate)
{
    const float2 size = bounds.zw;
    const float2 p = position - bounds.xy;
    const float tilt = abs(tiltAngle);

    if (tilt < 1e-5) {
        return toOpaque(layer.sample(position));
    }

    const bool hingeIsRight = tiltAngle > 0.0;
    const float hingeX = hingeIsRight ? size.x : 0.0;
    const float sign = hingeIsRight ? -1.0   : 1.0;
    const float d = abs(p.x - hingeX);

    const float3 glassPos = float3(
        hingeX + sign * d * cos(tilt),
        p.y,
        d * sin(tilt)
    );

    const float3 eye = float3(size * 0.5, eyeDistance);

    const float depth = eye.z - glassPos.z;
    if (depth <= 1e-3) {
        return half4(0.0h, 0.0h, 0.0h, 1.0h);
    }
    const float t = eye.z / depth;
    const float2 hitUV = eye.xy + (glassPos.xy - eye.xy) * t;

    const float gap = glassPos.z;
    const float radius = blurSpread * gap;

    if (any(hitUV < -radius) || any(hitUV > size + radius)) {
        return half4(0.0h, 0.0h, 0.0h, 1.0h);
    }

    const half attenuation = half(max(1.0 - dimRate * radius, 0.0));

    if (radius < 0.5) {
        return toOpaque(layer.sample(bounds.xy + hitUV) * attenuation);
    }

    const int taps = clamp(int(radius * 2.0), 6, kMaxTaps);
    const float rotation = rand2(position) * kTwoPi;
    half3 accumulated = half3(0.0h);

    for (int i = 0; i < taps; ++i) {
        float r = radius * sqrt((float(i) + 0.5) / float(taps));
        float a = float(i) * kGoldenAngle + rotation;
        float2 offset = r * float2(cos(a), sin(a));
        accumulated += layer.sample(bounds.xy + hitUV + offset).rgb;
    }

    return half4(accumulated / half(taps) * attenuation, 1.0h);
}
