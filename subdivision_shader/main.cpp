#include "main.h"
#include "glengine.h"

GLEngine engine;

void keyboard(unsigned char key, int x, int y) {
	engine.keyboard(key,x,y);
}

void display() {
	engine.display();
}

void reshape(int w, int h) {
	engine.reshape(w,h);
}


int main(int argc, char** argv)
{
	const unsigned int width = 1680;
	const unsigned int height = 1024;

	glutInit(&argc, argv);

	glutInitDisplayMode(GLUT_DOUBLE | GLUT_RGB | GLUT_DEPTH);

	glutInitWindowSize(width,height);
	glutCreateWindow("CS284 subdivision shader");

	GLenum err = glewInit();
	if (err != GLEW_OK) {
		std::cerr << "GLEW Error: " << glewGetString(err) << std::endl;
	}
	
	engine.reshape(width, height);
	engine.setupScene(); // Setup our OpenGL scene

	glutReshapeFunc(reshape);
	glutDisplayFunc(display);
	glutKeyboardFunc(keyboard);

	glutMainLoop();
	return 0;
}