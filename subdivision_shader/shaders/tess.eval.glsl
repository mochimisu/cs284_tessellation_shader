#version 400
 
layout (triangles, equal_spacing, ccw) in; // triangles, quads, or isolines
in vec3 evaluationpoint_wor[];

uniform mat4 projectionMatrix;
uniform mat4 viewMatrix;
uniform mat4 modelMatrix;
 
// gl_TessCoord is location within the patch (barycentric for triangles, UV for quads)
 
void main () {
  vec3 p0 = gl_TessCoord.x * evaluationpoint_wor[0]; // x is one corner
  vec3 p1 = gl_TessCoord.y * evaluationpoint_wor[1]; // y is the 2nd corner
  vec3 p2 = gl_TessCoord.z * evaluationpoint_wor[2]; // z is the 3rd corner (ignore when using quads)
  vec3 pos = p0 + p1 + p2;
  gl_Position = projectionMatrix * viewMatrix * modelMatrix * vec4 (pos, 1);
}