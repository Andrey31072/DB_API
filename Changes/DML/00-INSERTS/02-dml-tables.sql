INSERT INTO usuario VALUES
(gen_random_uuid(), 'Kevin Gómez', 'kevin@email.com', NOW()),
(gen_random_uuid(), 'Skleiner Lopez ', 'Skleiner@email.com', NOW());

INSERT INTO tarea VALUES
(gen_random_uuid(), 'Aprender Software', 'Estudiar Docker', 'PENDIENTE', NOW()),
(gen_random_uuid(), 'Crear Aplicación', 'Desarrollar frontend', 'FINALIZADA', NOW());