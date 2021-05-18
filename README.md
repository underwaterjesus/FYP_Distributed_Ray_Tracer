# Distributed Ray Tracing Module
<p align="justify">
This is the code base for my Final Year Computer Systems Project at the University of Limerick. The project is written entirely in the Julia programming language.
</p>
<p align="justify">
The goal of the project was to create a Julia module that allows users to create and render simple, static scenes using the ray tracing rendering technique, and to provide the option of performing rendering using a distributed computing cluster.
</p>
<p align="justify">
An overview of the functionality contained in the final version of the project is shown in the list below. A more detailed description of this functionality is given in the included <a href="https://github.com/underwaterjesus/FYP_Distributed_Ray_Tracer/blob/main/FYP_Report_12159603.pdf" title="FYP Report">report</a>, and the <a href="https://github.com/underwaterjesus/FYP_Distributed_Ray_Tracer/wiki" title="FYP Wiki">Wiki</a> section.

- adding simple shapes (cuboids & spheres) to a scene
- specifying the transparency, reflectivity, and refractive indices of shapes 
- adding a light source to a scene, and specifiying its brightness
- adding a positionable camera to a scene
- specifying a background colour
- executing the rendering function concurrently
- distributing the execution of the rendering function
- simulation of <a href="https://en.wikipedia.org/wiki/Total_internal_reflection" text="Wikipedia - Total internal reflection">total internal reflection</a> and the <a href="https://en.wikipedia.org/wiki/Fresnel_equations" text="Wikipedia - Fresnel equations">Fresnel effect</a>, using the <a href="https://en.wikipedia.org/wiki/Schlick%27s_approximation" text="Wikipedia - Schlick's approximation">Schlick approximation</a>
</p>

## Using The Module
<p align="justify">
Both the included <a href="https://github.com/underwaterjesus/FYP_Distributed_Ray_Tracer/blob/main/FYP_Report_12159603.pdf" title="FYP Report">report</a> and the <a href="https://github.com/underwaterjesus/FYP_Distributed_Ray_Tracer/wiki" title="FYP Wiki">Wiki</a> detail how to setup your Julia environment to use the module. They also provide a guide on how to use the module to create and render scenes. However, the information contained in the Wiki is more detailed.
</p>

## Corrections To The Report
<p align="justify">
Section 4.4.1 (p.33-36) details how to scale the size of the viewing plane to match the scene a user wishes to render. It also details how to determine the position of the plane in the scene coordinate system. These processes invlove the use of the tangent trigonometric function. This function involves using the sides adjacent and opposite the relevant angle of a right-angle triangle. In Section 4.4.1, I mistakenly claim it uses the hypotenuse, rather than the adjacent side. This means that Figure 4.9 is also incorrect.
</p>
<p align="justify">
On page 62, in Section 4.9, a mistake in the implementation of the <a href="https://en.wikipedia.org/wiki/Phong_reflection_model" title="Wikipedia - Phong reflection model">Phong Reflection Model</a> is mentioned. This mistake is in the version of the module that was submitted for grading. I was unable to rectify the error before the project deadline. However, the version of the project that is present in this repository has had this error rectified.
</p>

## Grade
<p align="justify">
The project is currently being graded. This section will be updated when a final grade has been received.
</p>
