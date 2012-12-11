#version 400
 
struct PnPatch
{
	float b012;
	float b021;
	float b120;
	float b210;
	float b201;
	float b102;
	float b111;

	float n011;
	float n110;
	float n101;
};

layout (vertices = 3) out; // number of CPs in patch

in vec3 controlpoint_wor[]; // from VS (use empty modifier [] so we can say anything)
in vec3 controlpoint_norm[];

out vec3 evaluationpoint_wor[]; // to evaluation shader. will be used to guide positioning of generated points
out vec3 evaluationpoint_norm[];

out PnPatch evaluationpoint_pnpatch[];
 
uniform float tessLevel; 
 
float wij(int i, int j)
{
 return dot(controlpoint_wor[j] - controlpoint_wor[i], controlpoint_norm[i]);
}
 
float vij(int i, int j)
{
 vec3 Pj_minus_Pi = controlpoint_wor[j]
                  - controlpoint_wor[i];
 vec3 Ni_plus_Nj  = controlpoint_norm[i] + controlpoint_norm[j];
 return 2.0*dot(Pj_minus_Pi, Ni_plus_Nj)/dot(Pj_minus_Pi, Pj_minus_Pi);
}

#define cur_patch evaluationpoint_pnpatch[gl_InvocationID]

void main () {


	float P0 = controlpoint_wor[0][gl_InvocationID];
	float P1 = controlpoint_wor[1][gl_InvocationID];
	float P2 = controlpoint_wor[2][gl_InvocationID];
	float N0 = controlpoint_norm[0][gl_InvocationID];
	float N1 = controlpoint_norm[1][gl_InvocationID];
	float N2 = controlpoint_norm[2][gl_InvocationID];

	float V = (P0 + P1 + P2)/3.;


	cur_patch.b210 = (2. * P0 + P1 - wij(0,1) * N0)/3.;
	cur_patch.b120 = (2. * P1 + P0 - wij(1,0) * N1)/3.;
	cur_patch.b021 = (2. * P1 + P2 - wij(1,2) * N1)/3.;
	cur_patch.b012 = (2. * P2 + P1 - wij(2,1) * N2)/3.;
	cur_patch.b102 = (2. * P2 + P0 - wij(2,0) * N2)/3.;
	cur_patch.b201 = (2. * P0 + P2 - wij(2,0) * N0)/3.;
	float E = ( cur_patch.b210
	  + cur_patch.b120
	  + cur_patch.b021
	  + cur_patch.b012
	  + cur_patch.b102
	  + cur_patch.b201 ) / 6.;
	
	cur_patch.b111 = E + (E - V) * 0.5;

	cur_patch.n110 = N0 + N1 - vij(0,1) * (P1-P0);
	cur_patch.n110 = N1 + N2 - vij(1,2) * (P2-P1);
	cur_patch.n110 = N2 + N0 - vij(2,0) * (P0-P2);

	evaluationpoint_wor[gl_InvocationID] = controlpoint_wor[gl_InvocationID];
	evaluationpoint_norm[gl_InvocationID] = controlpoint_norm[gl_InvocationID];

	// Calculate the tessellation levels
	gl_TessLevelInner[0] = tessLevel;
	gl_TessLevelOuter[gl_InvocationID] = tessLevel; 
}