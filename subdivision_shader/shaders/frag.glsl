#version 400

in vec3 frag_norm;
in vec3 frag_pos;
 
out vec4 fragcolor;
 
void main () {
	vec3 light_pos = vec3(0,10,5);

	vec3 direction = normalize(light_pos-frag_pos);

	float ndl = max(dot(frag_norm, direction),0);
	fragcolor = vec4(ndl, ndl, ndl, 1);
}