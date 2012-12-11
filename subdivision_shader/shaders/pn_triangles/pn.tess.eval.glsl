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

layout (triangles, equal_spacing, ccw) in; // triangles, quads, or isolines
in vec3 evaluationpoint_wor[];
in vec3 evaluationpoint_norm[];
in PnPatch evaluationpoint_pnpatch[];

out vec3 te_position;
out vec3 te_patch_distance;
out vec3 te_norm;

uniform mat4 projectionMatrix;
uniform mat4 viewMatrix;
uniform mat4 modelMatrix;
uniform mat4 normalMatrix;

uniform float alpha;
 
void main () {

	vec3 tesscoord2 = gl_TessCoord * gl_TessCoord;
	vec3 tesscoord3 = tesscoord2 * gl_TessCoord;

	vec3 b012 = vec3(evaluationpoint_pnpatch[0].b012, evaluationpoint_pnpatch[1].b012, evaluationpoint_pnpatch[2].b012);
	vec3 b021 = vec3(evaluationpoint_pnpatch[0].b021, evaluationpoint_pnpatch[1].b021, evaluationpoint_pnpatch[2].b021);
	vec3 b120 = vec3(evaluationpoint_pnpatch[0].b120, evaluationpoint_pnpatch[1].b120, evaluationpoint_pnpatch[2].b120);
	vec3 b210 = vec3(evaluationpoint_pnpatch[0].b210, evaluationpoint_pnpatch[1].b210, evaluationpoint_pnpatch[2].b210);
	vec3 b201 = vec3(evaluationpoint_pnpatch[0].b201, evaluationpoint_pnpatch[1].b201, evaluationpoint_pnpatch[2].b201);
	vec3 b102 = vec3(evaluationpoint_pnpatch[0].b102, evaluationpoint_pnpatch[1].b102, evaluationpoint_pnpatch[2].b102);
	vec3 b111 = vec3(evaluationpoint_pnpatch[0].b111, evaluationpoint_pnpatch[1].b111, evaluationpoint_pnpatch[2].b111);

	vec3 n011 = normalize(vec3(evaluationpoint_pnpatch[0].n011, evaluationpoint_pnpatch[1].n011, evaluationpoint_pnpatch[2].n011));
	vec3 n110 = normalize(vec3(evaluationpoint_pnpatch[0].n110, evaluationpoint_pnpatch[1].n110, evaluationpoint_pnpatch[2].n110));
	vec3 n101 = normalize(vec3(evaluationpoint_pnpatch[0].n101, evaluationpoint_pnpatch[1].n101, evaluationpoint_pnpatch[2].n101));

	vec3 pn_norm = evaluationpoint_norm[0]*tesscoord2[2]
		+ evaluationpoint_norm[1]*tesscoord2[0]
		+ evaluationpoint_norm[2]*tesscoord2[1]
		+ n011*gl_TessCoord[0]*gl_TessCoord[1]
		+ n110*gl_TessCoord[2]*gl_TessCoord[0]
		+ n101*gl_TessCoord[2]*gl_TessCoord[1];

	vec3 pn_pos = evaluationpoint_wor[0]*tesscoord3[2]
		+ evaluationpoint_wor[1]*tesscoord3[0]
		+ evaluationpoint_wor[2]*tesscoord3[1]
		+ b210*3.*tesscoord2[2]*gl_TessCoord[0]
		+ b120*3.*tesscoord2[0]*gl_TessCoord[2]
		+ b201*3.*tesscoord2[2]*gl_TessCoord[1]
		+ b021*3.*tesscoord2[0]*gl_TessCoord[1]
		+ b102*3.*tesscoord2[1]*gl_TessCoord[2]
		+ b012*3.*tesscoord2[1]*gl_TessCoord[0] 
		+ b111*6.*gl_TessCoord[0]*gl_TessCoord[1]*gl_TessCoord[2];

	vec3 p0 = gl_TessCoord.x * evaluationpoint_wor[0]; // x is one corner
	vec3 p1 = gl_TessCoord.y * evaluationpoint_wor[1]; // y is the 2nd corner
	vec3 p2 = gl_TessCoord.z * evaluationpoint_wor[2]; // z is the 3rd corner (ignore when using quads)
	vec3 pos = p0 + p1 + p2;

	vec3 n0 = gl_TessCoord.x * evaluationpoint_norm[0];
	vec3 n1 = gl_TessCoord.y * evaluationpoint_norm[1];
	vec3 n2 = gl_TessCoord.z * evaluationpoint_norm[2];
	vec3 norm = n0 + n1 + n2;

	//pn_norm = alpha * pn_norm + (1.-alpha) * norm;
	//pn_pos = alpha * pn_pos + (1.-alpha) * pos;

	vec4 _norm = normalMatrix * vec4(pn_norm,1);
	te_norm = _norm.xyz;
	vec4 _pos = viewMatrix * modelMatrix * vec4(pn_pos,1);
	te_patch_distance = gl_TessCoord;
	te_position = _pos.xyz/_pos.w;

	gl_Position = projectionMatrix * viewMatrix * modelMatrix * vec4 (pn_pos, 1);
}