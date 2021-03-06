#version 300 es

precision highp float;
precision highp int;

#include "noise/noise2D.glsl"
#include "render-utils.glsl"

//layout(location = 0) in float a_ParticleIndex;
layout(location = 0) in vec2 a_VertexPosition;

out vec4 v_Color;

uniform sampler2D ParticleData0; // |   Pos X   |   Pos Y   |   Pos Z   |  Dir XYZ  |
uniform sampler2D ParticleData1; // | LifeCount | Lifetime  |   Index   |   Seed    |
uniform sampler2D ColorTable;
uniform ivec2 ID2TPos;

uniform mat4 ViewMatrix;
uniform mat4 ProjMatrix;

vec2 rotate(vec2 pos, float deg)
{
	const float toRad = 3.141592 / 180.0;
	float c = cos(deg * toRad);
	float s = sin(deg * toRad);
	return mat2(c, -s, s, c) * pos;
}

void main() {
	//int particleID = int(a_ParticleIndex);
	int particleID = gl_InstanceID;
	ivec2 texPos = ivec2(particleID & ID2TPos.x, particleID >> ID2TPos.y);
	vec4 data0 = texelFetch(ParticleData0, texPos, 0);
	vec4 data1 = texelFetch(ParticleData1, texPos, 0);
	
	float age = data1.x;
	float lifetime = data1.y;

	if (age >= lifetime) {
		gl_Position = vec4(0.0);
		v_Color = vec4(0.0);
	} else {
		vec3 position = data0.xyz;
		position.xyz += vec3(rotate(a_VertexPosition * 0.003, 45.0), 0.0);
		gl_Position = ProjMatrix * ViewMatrix * vec4(position, 1.0);
		
		vec2 texCoord = vec2(snoise(vec2(texPos) / 512.0));
		v_Color = texture(ColorTable, texCoord);
		v_Color.a *= fadeInOut(1.0, 10.0, age, lifetime);
	}
}
