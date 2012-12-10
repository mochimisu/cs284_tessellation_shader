#include "main.h"
#include "shader.h"
#include "objloader.h"

#ifndef __GLENGINE_H_
#define __GLENGINE_H_

class GLEngine {
public:
	GLEngine(void); 
	~GLEngine(void); 
	void setupScene(void); // Initialization
	void reshape(int w, int h); // Resizing window
	void display(void); // Show the scene
	void keyboard(unsigned char key, int x, int y); // Keyboard interaction

	void createSquare(void); // Method for creating our squares Vertex Array Object

private:
	int window_width; // Store the width of our window
	int window_height; // Store the height of our window

	Shader *shader; // Our GLSL shader
	ObjLoader obj;

	glm::mat4 projection_matrix; // Store the projection matrix
	glm::mat4 view_matrix; // Store the view matrix
	glm::mat4 model_matrix; // Store the model matrix

	unsigned int vao_id[1]; // Our Vertex Array Object
	unsigned int vbo_id[1]; // Our Vertex Buffer Object

	float tess_level_inner;
	float tess_level_outer;

	bool inited;
};

#endif