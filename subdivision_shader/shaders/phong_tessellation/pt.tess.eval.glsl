#version 400

struct PhongPatch
{
	float ij;
	float jk;
	float ik;
};

layout (triangles, equal_spacing, ccw) in; // triangles, quads, or isolines
in vec3 evaluationpoint_wor[];
in vec3 evaluationpoint_norm[];
in PhongPatch evaluationpoint_phongpatch[];

out vec3 te_position;
out vec3 te_patch_distance;
out vec3 te_norm;

uniform mat4 projectionMatrix;
uniform mat4 viewMatrix;
uniform mat4 modelMatrix;
uniform mat4 normalMatrix;
 
// gl_TessCoord is location within the patch (barycentric for triangles, UV for quads)
 
void main () {


	vec3 tess_coord_sq = gl_TessCoord * gl_TessCoord;

	vec3 ij = vec3(evaluationpoint_phongpatch[0].ij,
		evaluationpoint_phongpatch[1].ij,
		evaluationpoint_phongpatch[2].ij);
	vec3 jk = vec3(evaluationpoint_phongpatch[0].jk,
		evaluationpoint_phongpatch[1].jk,
		evaluationpoint_phongpatch[2].jk);
	vec3 ik = vec3(evaluationpoint_phongpatch[0].ik,
		evaluationpoint_phongpatch[1].ik,
		evaluationpoint_phongpatch[2].ik);
	vec3 phong_pos = tess_coord_sq[0]*evaluationpoint_wor[0]
				   + tess_coord_sq[1]*evaluationpoint_wor[1]
				   + tess_coord_sq[2]*evaluationpoint_wor[2]
				   + gl_TessCoord[0]*gl_TessCoord[1]*ij
				   + gl_TessCoord[1]*gl_TessCoord[2]*jk
				   + gl_TessCoord[0]*gl_TessCoord[2]*ik;


	vec3 p0 = gl_TessCoord.x * evaluationpoint_wor[0]; // x is one corner
	vec3 p1 = gl_TessCoord.y * evaluationpoint_wor[1]; // y is the 2nd corner
	vec3 p2 = gl_TessCoord.z * evaluationpoint_wor[2]; // z is the 3rd corner (ignore when using quads)
	vec3 pos = p0 + p1 + p2;

	vec3 n0 = gl_TessCoord.x * evaluationpoint_norm[0];
	vec3 n1 = gl_TessCoord.y * evaluationpoint_norm[1];
	vec3 n2 = gl_TessCoord.z * evaluationpoint_norm[2];
	vec3 norm = n0 + n1 + n2;

	vec4 _norm = normalMatrix * vec4(norm,1);
	te_norm = _norm.xyz;
	vec4 _pos = viewMatrix * modelMatrix * vec4(pos,1);
	te_patch_distance = gl_TessCoord;
	te_position = _pos.xyz/_pos.w;

	gl_Position = projectionMatrix * viewMatrix * modelMatrix * vec4 (phong_pos, 1);
}