# HISTORIAS DE USUARIOS SPRINT 2 - BUGAREPORT

## 1. Gestión de cuadrantes geográficos:

Como administrador de BugaReport, quiero crear, modificar y eliminar cuadrantes geográficos dentro de Guadalajara de Buga, para organizar territorialmente los reportes ciudadanos y facilitar su distribución entre los responsables.

**Criterios de aceptación:**

- El administrador debe poder crear un cuadrante asignándole un nombre y una descripción.
- Debe poder delimitar el cuadrante mediante puntos o coordenadas en un mapa.
- El sistema debe permitir modificar los límites de un cuadrante existente.
- Debe ser posible eliminar cuadrantes que no tengan reportes activos asignados.
- El sistema debe identificar los cuadrantes existentes para evitar delimitaciones superpuestas no permitidas.

## 2. Historial de seguimiento de incidentes

**Título:** Implementar historial de seguimiento de los incidentes.

Como administrador,
quiero consultar el historial de modificaciones de cada incidente,
para conocer las acciones realizadas y verificar el seguimiento de cada reporte.

**Descripción:**

Desarrollar una sección donde se pueda consultar la trazabilidad de los incidentes, incluyendo los cambios de estado, fechas de actualización y observaciones realizadas por los administradores.

**Criterios de aceptación:**

- Cada incidente debe tener una sección de historial.
- Se deben registrar las fechas de las modificaciones.
- Se debe identificar el administrador que realizó cada modificación.
- Se deben visualizar las observaciones asociadas a cada actualización.
- El historial debe estar organizado cronológicamente.

## 3. Asignación de personal responsable:

Como administrador, quiero asignar ingenieros y técnicos responsables a cada reporte ciudadano, para organizar las actividades necesarias para atender los problemas identificados.

**Criterios de aceptación:**

- El administrador debe poder consultar el personal disponible.
- Debe poder asignar un ingeniero como responsable de supervisión.
- Debe poder asignar un técnico encargado de la atención operativa.
- El sistema debe guardar los responsables asociados al reporte.
- Debe mostrarse el nombre y cargo de los responsables asignados.
- El administrador debe poder cambiar los responsables cuando sea necesario.

## 4. Reasignación de reportes entre cuadrantes y responsables

Como administrador, quiero reasignar un reporte a otro cuadrante o responsable cuando sea necesario, para corregir asignaciones incorrectas y mantener una distribución adecuada del trabajo.

**Criterios de aceptación:**

- El administrador debe poder seleccionar un reporte existente.
- Debe poder modificar el cuadrante asociado al reporte.
- Debe poder cambiar el ingeniero o técnico responsable.
- El sistema debe guardar los cambios realizados.
- Debe conservarse el registro de la asignación anterior y la nueva.
- El reporte debe reflejar los responsables y cuadrante actualizados.

## 5. Control de carga de trabajo del personal:

Como administrador, quiero consultar la cantidad de reportes asignados a cada ingeniero y técnico, para distribuir equilibradamente las actividades y evitar la sobrecarga de trabajo.

**Criterios de aceptación:**

- El panel debe mostrar los reportes asignados a cada responsable.
- Debe indicar cuántos reportes tiene pendientes cada integrante.
- Debe permitir identificar al personal con mayor cantidad de asignaciones.
- El administrador debe poder consultar los detalles de las asignaciones.
- La información debe actualizarse cuando se realicen nuevas asignaciones o reasignaciones.

## 6. Visualización interactiva de incidentes en el mapa:

**Título:** Implementar mapa interactivo de incidentes en el panel administrativo.

Como administrador, quiero visualizar los incidentes registrados en un mapa interactivo de Buga, para identificar las zonas con mayor concentración de reportes y facilitar su gestión.

**Descripción:**

Integrar Leaflet al panel administrativo para representar geográficamente los incidentes mediante marcadores que permitan consultar información específica de cada reporte.

**Criterios de aceptación:**

- El mapa debe mostrar los incidentes según sus coordenadas geográficas.
- Cada incidente debe tener un marcador identificable.
- Al seleccionar un marcador se debe mostrar información básica del incidente.
- El mapa debe permitir acercar, alejar y desplazarse por la zona geográfica.
- Los marcadores deben actualizarse cuando se registren nuevos incidentes.

## 7. Implementación de filtros y búsqueda avanzada:

**Título:** Desarrollar módulo de filtros y búsqueda avanzada de incidentes.

Como administrador, quiero filtrar y buscar incidentes utilizando diferentes criterios, para encontrar rápidamente los reportes que necesito gestionar.

**Descripción:**

Implementar filtros dentro del panel administrativo que permitan consultar incidentes por categoría, estado, fecha y cuadrante asignado.

**Criterios de aceptación:**

- El sistema debe permitir filtrar por categoría del incidente.
- Debe permitir filtrar por estado del reporte.
- Debe permitir seleccionar rangos de fechas.
- Debe permitir filtrar por cuadrante.
- Los resultados deben actualizarse de acuerdo con los filtros seleccionados.
- Debe existir una opción para limpiar los filtros aplicados.

## 8. Implementar detección y gestión de incidentes duplicados.

Como administrador del sistema, quiero identificar reportes ciudadanos que correspondan a un mismo incidente, para evitar registros duplicados y facilitar una gestión más organizada de los casos.

**Descripción:**

Desarrollar una funcionalidad que permita identificar posibles reportes duplicados mediante la comparación de su categoría, ubicación geográfica y fecha de registro. El administrador podrá revisar los reportes relacionados y determinar si corresponden al mismo incidente o si deben mantenerse como casos independientes.

**Criterios de aceptación:**

- El sistema debe identificar posibles reportes duplicados según su categoría, ubicación y proximidad temporal.
- El administrador debe poder visualizar los detalles de los reportes identificados.
- Se debe permitir marcar un reporte como duplicado de otro.
- El administrador debe poder descartar una coincidencia cuando los reportes correspondan a incidentes diferentes.
- Los reportes relacionados deben conservar su información original.
- El sistema debe registrar las decisiones tomadas en el historial de seguimiento.

## 9. Generación y descarga de informes:

**Título:** Implementar exportación de informes de incidentes.

Como administrador,
quiero generar y descargar informes de los incidentes registrados,
para disponer de información organizada que facilite el análisis y la toma de decisiones.

**Descripción:**

Implementar una funcionalidad que permita exportar los registros de incidentes en formatos CSV y PDF.

**Criterios de aceptación:**

- El administrador puede solicitar la generación de un informe.
- El sistema permite descargar informes en formato CSV.
- El sistema permite generar informes en PDF.
- Los informes deben incluir fecha, categoría, ubicación y estado del incidente.
- La información exportada debe corresponder a los registros consultados.

## 10. Gestión de notificaciones administrativas

**Título:** Implementar módulo de notificaciones para administradores.

Como administrador,
quiero recibir notificaciones sobre nuevos incidentes y actualizaciones importantes,
para mantenerme informado y atender oportunamente los reportes ciudadanos.

**Descripción:**

Crear un módulo de notificaciones dentro del panel administrativo que permita identificar nuevos reportes y cambios importantes en los incidentes.

**Criterios de aceptación:**

- El sistema debe notificar cuando se registre un nuevo incidente.
- Las notificaciones deben identificar el tipo de evento.
- Se debe visualizar la fecha de cada notificación.
- El administrador puede marcar las notificaciones como leídas.
- Las notificaciones deben dirigir al incidente correspondiente.

## 11. Desarrollar servicio de consulta de incidentes para exportación de informes.

Desarrollar la lógica de consulta en Supabase para recuperar los incidentes registrados, aplicar los filtros seleccionados por el administrador y proporcionar los datos necesarios para generar informes en formatos CSV y PDF desde el panel administrativo.

**Criterios de aceptación:**

- El servicio debe recuperar los incidentes almacenados en Supabase.
- Debe aceptar filtros por categoría, estado, fecha y cuadrante.
- Debe devolver únicamente los registros que coincidan con los criterios seleccionados.
- Debe entregar los datos con una estructura compatible con la generación de archivos CSV y PDF.
- Debe respetar los permisos de acceso de los administradores.

Esta tarea se desarrolla antes de completar la integración de HU2. HU6 proporciona los criterios de filtrado que utilizarán ambas funcionalidades.

## 12. Visualización de indicadores generales (Dashboard)

**Título:** Implementar dashboard de indicadores generales de incidentes.

Como administrador del sistema,
quiero visualizar indicadores generales de los incidentes reportados,
para conocer el comportamiento y el estado actual de los reportes ciudadanos.

**Descripción:**

Desarrollar un dashboard que permita visualizar información estadística de los incidentes registrados en BugaReport mediante tarjetas de indicadores y gráficas.

**Criterios de aceptación:**

- El dashboard debe mostrar el total de incidentes registrados.
- Debe mostrar la cantidad de incidentes pendientes, en proceso y resueltos.
- Debe presentar gráficas de incidentes por categoría.
- Debe mostrar estadísticas de incidentes por periodo de tiempo.
- Los indicadores deben actualizarse cuando existan nuevos registros o cambios en los reportes.
