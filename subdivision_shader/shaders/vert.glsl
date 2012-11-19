#version 400

in vec3 vp_loc;
out vec3 controlpoint_wor;

void main(void)
{
     controlpoint_wor = vp_loc;
}