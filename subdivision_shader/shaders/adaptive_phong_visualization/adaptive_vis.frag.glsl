#version 400

in vec3 g_normal;
in vec3 g_patch_distance;
in vec3 g_tri_distance;
in vec4 g_position;
in float g_primitive;
in float g_d;
 
out vec4 frag_color;

void main () {
	float d = g_d/10.;
	frag_color = vec4(d,0,0,1);
}