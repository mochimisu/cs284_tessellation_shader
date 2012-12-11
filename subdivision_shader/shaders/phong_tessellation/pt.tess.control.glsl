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
 
uniform float tessLevelInner; // controlled by keyboard buttons
uniform float tessLevelOuter; // controlled by keyboard buttons
 
float PIi(int i, vec3 q)
{
	vec3 q_minus_p = q - controlpoint_wor[i];
	return q[gl_InvocationID] - dot(q_minus_p, controlpoint_norm[i]) * controlpoint_norm[i][gl_InvocationID];
}

void main () {

	evaluationpoint_phongpatch[gl_InvocationID].ij = PIi(0, controlpoint_wor[1]) + PIi(1, controlpoint_wor[0]);
	evaluationpoint_phongpatch[gl_InvocationID].jk = PIi(1, controlpoint_wor[2]) + PIi(2, controlpoint_wor[1]);
	evaluationpoint_phongpatch[gl_InvocationID].ik = PIi(2, controlpoint_wor[0]) + PIi(0, controlpoint_wor[2]);


	evaluationpoint_wor[gl_InvocationID] = controlpoint_wor[gl_InvocationID];
	evaluationpoint_norm[gl_InvocationID] = controlpoint_norm[gl_InvocationID];

	// Calculate the tessellation levels
	gl_TessLevelInner[0] = tessLevelInner;
	gl_TessLevelOuter[gl_InvocationID] = tessLevelOuter; 
}