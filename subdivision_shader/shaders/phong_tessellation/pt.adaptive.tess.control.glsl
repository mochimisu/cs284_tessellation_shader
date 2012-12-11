#version 400
 
struct PhongPatch
{
	float ij;
	float jk;
	float ik;
};

layout (vertices = 3) out; // number of CPs in patch

in vec3 controlpoint_wor[]; // from VS (use empty modifier [] so we can say anything)
in vec3 controlpoint_norm[];

out vec3 evaluationpoint_wor[]; // to evaluation shader. will be used to guide positioning of generated points
out vec3 evaluationpoint_norm[];

out PhongPatch evaluationpoint_phongpatch[];
out float evaluationpoint_d[];
 
uniform float tessLevel;
uniform vec3 camera;
uniform mat4 projectionMatrix;
uniform mat4 viewMatrix;
uniform mat4 modelMatrix;
uniform mat4 normalMatrix;

float PIi(int i, vec3 q)
{
	vec3 q_minus_p = q - controlpoint_wor[i];
	return q[gl_InvocationID] - dot(q_minus_p, controlpoint_norm[i]) * controlpoint_norm[i][gl_InvocationID];
}

void main () {

	vec4 _cpw0 = viewMatrix*modelMatrix*vec4(controlpoint_wor[0],1);
	vec4 _cpw1 = viewMatrix*modelMatrix*vec4(controlpoint_wor[1],1);
	vec4 _cpw2 = viewMatrix*modelMatrix*vec4(controlpoint_wor[2],1);

	vec3 cpw0 = _cpw0.xyz/_cpw0.w;
	vec3 cpw1 = _cpw1.xyz/_cpw1.w;
	vec3 cpw2 = _cpw2.xyz/_cpw2.w;
	vec3 cpw_avg = (cpw0+cpw1+cpw2)/3.;

	vec4 _cpn0 = normalMatrix*vec4(controlpoint_norm[0],1);
	vec4 _cpn1 = normalMatrix*vec4(controlpoint_norm[1],1);
	vec4 _cpn2 = normalMatrix*vec4(controlpoint_norm[2],1);

	vec3 cpn0 = _cpn0.xyz;
	vec3 cpn1 = _cpn1.xyz;
	vec3 cpn2 = _cpn2.xyz;


	vec3 dist = vec3(
		dot(cpn0, normalize(camera - cpw0)),
		dot(cpn1, normalize(camera - cpw1)),
		dot(cpn2, normalize(camera - cpw2)));

	evaluationpoint_d[gl_InvocationID] = (1 - length(dist));

	evaluationpoint_phongpatch[gl_InvocationID].ij = PIi(0, controlpoint_wor[1]) + PIi(1, controlpoint_wor[0]);
	evaluationpoint_phongpatch[gl_InvocationID].jk = PIi(1, controlpoint_wor[2]) + PIi(2, controlpoint_wor[1]);
	evaluationpoint_phongpatch[gl_InvocationID].ik = PIi(2, controlpoint_wor[0]) + PIi(0, controlpoint_wor[2]);


	evaluationpoint_wor[gl_InvocationID] = controlpoint_wor[gl_InvocationID];
	evaluationpoint_norm[gl_InvocationID] = controlpoint_norm[gl_InvocationID];

	// Calculate the tessellation levels
	float adaptive_tessLevel = max((1-length(dist)) * tessLevel,1);
	//adaptive_tessLevel *= 2./length(camera-cpw_avg);
	gl_TessLevelInner[0] = adaptive_tessLevel;
	gl_TessLevelOuter[gl_InvocationID] = adaptive_tessLevel; 
	evaluationpoint_d[gl_InvocationID] = adaptive_tessLevel;
}