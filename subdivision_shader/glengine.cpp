#include "glengine.h"

GLEngine::GLEngine(void)
{
	inited = false;
	rot_orientation = glm::mat4(1.f);
	mouse_pos = glm::vec2(0.);
	mouse_state = GLUT_LEFT_BUTTON;
	scene_scale = 0.25;
	scene_translate = glm::vec3(0.f,-1.f,0.f);
}

GLEngine::~GLEngine(void)
{
	if (inited)
	{
		delete(shader);
	}
}

void GLEngine::setupScene(void)
{
	glClearColor(0.4f, 0.6f, 0.9f, 0.0f); 
	//glPolygonMode(GL_FRONT_AND_BACK,GL_LINE);

	shader = new Shader();
	shader->initShader(GL_VERTEX_SHADER, "shaders/vert.glsl");
	shader->initShader(GL_TESS_CONTROL_SHADER, "shaders/tess.control.glsl");
	shader->initShader(GL_TESS_EVALUATION_SHADER, "shaders/tess.eval.glsl");
	shader->initShader(GL_GEOMETRY_SHADER, "shaders/geometry.glsl");
	shader->initShader(GL_FRAGMENT_SHADER, "shaders/frag.glsl");
	shader->initProgram();

	projection_matrix = glm::perspective(60.0f, (float)window_width / (float)window_height, 0.1f, 100.f);  // Create our perspective matrix

	tess_level_inner = 1;
	tess_level_outer = 1;
	inited = true;
	
	obj.loadObj("data/cube.obj");
	
	glEnable(GL_DEPTH_TEST);


}


void GLEngine::reshape(int w, int h)
{
	window_width = w; // Set the window width
	window_height = h; // Set the window height
}

void GLEngine::mouseFunc(int button, int state, int x, int y)
{
	if (state == GLUT_DOWN)
	{
		mouse_state = button;
	}
}

void GLEngine::activeMotion(int x, int y)
{
	glm::vec2 new_mouse = glm::vec2((double) x / window_width,
		(double) y / window_height);
	glm::vec2 diff = new_mouse - mouse_pos;

	float len = glm::dot(diff, diff);

	if ( len > 0.00001)
	{
		if (mouse_state == GLUT_LEFT_BUTTON)
		{
			glm::vec3 axis(diff[1]/len, diff[0]/len, 0.f);
			axis /= axis.length();
			rot_orientation = glm::rotate(rot_orientation, 20*180*len, axis);
		} else if (mouse_state == GLUT_RIGHT_BUTTON)
		{
			if (scene_scale + diff.x > 0)
			{
				scene_scale += diff.x;
			}
		} else if (mouse_state == GLUT_MIDDLE_BUTTON)
		{
			scene_translate.x += diff.x*4;
			scene_translate.y -= diff.y*4;
		}
	}

	mouse_pos = new_mouse;

	glutPostRedisplay();
}

void GLEngine::passiveMotion(int x, int y)
{
	glm::vec2 new_mouse = glm::vec2((double) x / window_width,
		(double) y / window_height);
	mouse_pos = new_mouse;

	glutPostRedisplay();
}

void GLEngine::keyboard(unsigned char key, int x, int y)
{
	int tess_delta = 1;
	switch(key) 
	{
	  case 27:
		  exit(0);
		  break;
	  case 'q':
		  tess_delta = -1;
	  case 'w':
		  if ((tess_level_inner + tess_delta) > 0) {
			tess_level_inner += tess_delta;
		  }
		  if ((tess_level_outer + tess_delta) > 0) {
			tess_level_outer += tess_delta;
		  }
	}
	glutPostRedisplay();
}


void GLEngine::display(void)
{
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT | GL_STENCIL_BUFFER_BIT); // Clear required buffers

	view_matrix = glm::translate(glm::mat4(1.0f), glm::vec3(0.0f, 0.0f, -5.f)); // Create our view matrix
	model_matrix = glm::translate(glm::mat4(1.0f), scene_translate) * glm::scale(glm::mat4(1.0f), glm::vec3(scene_scale)) * rot_orientation;  // Create our model matrix
	normal_matrix = glm::transpose(glm::inverse(view_matrix*model_matrix));

	shader->bind(); // Bind our shader

	int projectionMatrixLocation = glGetUniformLocation(shader->id(), "projectionMatrix"); // Get the location of our projection matrix in the shader
	int viewMatrixLocation = glGetUniformLocation(shader->id(), "viewMatrix"); // Get the location of our view matrix in the shader
	int modelMatrixLocation = glGetUniformLocation(shader->id(), "modelMatrix"); // Get the location of our model matrix in the shader
	int normalMatrixLocation = glGetUniformLocation(shader->id(), "normalMatrix"); // Get the location of our normal matrix in the shader
	int tli_loc = glGetUniformLocation(shader->id(), "tessLevelInner");
	int tlo_loc = glGetUniformLocation(shader->id(), "tessLevelOuter");

	glUniformMatrix4fv(projectionMatrixLocation, 1, GL_FALSE, &projection_matrix[0][0]); // Send our projection matrix to the shader
	glUniformMatrix4fv(viewMatrixLocation, 1, GL_FALSE, &view_matrix[0][0]); // Send our view matrix to the shader
	glUniformMatrix4fv(modelMatrixLocation, 1, GL_FALSE, &model_matrix[0][0]); // Send our model matrix to the shader
	glUniformMatrix4fv(normalMatrixLocation, 1, GL_FALSE, &normal_matrix[0][0]); // Send our model matrix to the shader
	glUniform1f(tli_loc, tess_level_inner);
	glUniform1f(tlo_loc, tess_level_outer);


	glPatchParameteri(GL_PATCH_VERTICES, 3);

	obj.upload();
	obj.draw(shader);
	
	shader->unbind(); // Unbind our shader

	glutSwapBuffers(); // Swap buffers so we can see our rendering
}
