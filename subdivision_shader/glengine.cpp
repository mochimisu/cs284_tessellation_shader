#include "glengine.h"

GLEngine::GLEngine(void)
{
	inited = false;
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
	glPolygonMode(GL_FRONT_AND_BACK,GL_LINE);

	shader = new Shader();
	shader->initShader(GL_VERTEX_SHADER, "shaders/vert.glsl");
	shader->initShader(GL_FRAGMENT_SHADER, "shaders/frag.glsl");
	shader->initShader(GL_TESS_CONTROL_SHADER, "shaders/tess.control.glsl");
	shader->initShader(GL_TESS_EVALUATION_SHADER, "shaders/tess.eval.glsl");
	shader->initProgram();

	projection_matrix = glm::perspective(60.0f, (float)window_width / (float)window_height, 0.1f, 100.f);  // Create our perspective matrix

	createSquare(); // Create our square

	tess_level_inner = 1;
	tess_level_outer = 1;
	inited = true;
	
	obj.loadObj("dragon.obj");

}


void GLEngine::reshape(int w, int h)
{
	window_width = w; // Set the window width
	window_height = h; // Set the window height
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
	model_matrix = glm::scale(glm::mat4(1.0f), glm::vec3(0.25f));  // Create our model matrix

	shader->bind(); // Bind our shader

	int projectionMatrixLocation = glGetUniformLocation(shader->id(), "projectionMatrix"); // Get the location of our projection matrix in the shader
	int viewMatrixLocation = glGetUniformLocation(shader->id(), "viewMatrix"); // Get the location of our view matrix in the shader
	int modelMatrixLocation = glGetUniformLocation(shader->id(), "modelMatrix"); // Get the location of our model matrix in the shader
	int tli_loc = glGetUniformLocation(shader->id(), "tessLevelInner");
	int tlo_loc = glGetUniformLocation(shader->id(), "tessLevelOuter");

	glUniformMatrix4fv(projectionMatrixLocation, 1, GL_FALSE, &projection_matrix[0][0]); // Send our projection matrix to the shader
	glUniformMatrix4fv(viewMatrixLocation, 1, GL_FALSE, &view_matrix[0][0]); // Send our view matrix to the shader
	glUniformMatrix4fv(modelMatrixLocation, 1, GL_FALSE, &model_matrix[0][0]); // Send our model matrix to the shader
	glUniform1f(tli_loc, tess_level_inner);
	glUniform1f(tlo_loc, tess_level_outer);


	glPatchParameteri(GL_PATCH_VERTICES, 3);

	obj.upload();
	obj.draw(shader);
	
	shader->unbind(); // Unbind our shader

	glutSwapBuffers(); // Swap buffers so we can see our rendering
}


void GLEngine::createSquare(void)
{
	float* vertices = new float[18];	// Vertices for our square

	vertices[0] = -0.5; vertices[1] = -0.5; vertices[2] = 0.0; // Bottom left corner
	vertices[3] = -0.5; vertices[4] = 0.5; vertices[5] = 0.0; // Top left corner
	vertices[6] = 0.5; vertices[7] = 0.5; vertices[8] = 0.0; // Top Right corner

	vertices[9] = 0.5; vertices[10] = -0.5; vertices[11] = 0.0; // Bottom right corner
	vertices[12] = -0.5; vertices[13] = -0.5; vertices[14] = 0.0; // Bottom left corner
	vertices[15] = 0.5; vertices[16] = 0.5; vertices[17] = 0.0; // Top Right corner

	glGenVertexArrays(1, &vao_id[0]); // Create our Vertex Array Object

	glBindVertexArray(vao_id[0]); // Bind our Vertex Array Object so we can use it
	
	glGenBuffers(1, vbo_id); // Generate our Vertex Buffer Object
	
	glBindBuffer(GL_ARRAY_BUFFER, vbo_id[0]); // Bind our Vertex Buffer Object
	glBufferData(GL_ARRAY_BUFFER, 18 * sizeof(GLfloat), vertices, GL_STATIC_DRAW); // Set the size and data of our VBO and set it to STATIC_DRAW
	glVertexAttribPointer((GLuint)0, 3, GL_FLOAT, GL_FALSE, 0, 0); // Set up our vertex attributes pointer
	
	glEnableVertexAttribArray(0); // Disable our Vertex Array Object
	glBindVertexArray(0); // Disable our Vertex Buffer Object

	delete [] vertices; // Delete our vertices from memory
}

