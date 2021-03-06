:tocdepth: 3

****************
Science Guide
****************

.. _coupl:

Coupling with host models
==================================

Sea ice models exchange information with 
other components of the earth system via a flux coupler. This is done
through the full CICE model and a thorough description of coupling sea
ice through a flux coupler can be found in the `CICE model 
documentation <https://CICE-Consortium.github.io/CICE/index.html>`_. 
Important information related to flux coupling associated
with the Icepack submodule will be discussed below, 
along with information about the interface between Icepack and CICE or
other host sea ice models.

.. _intfc:

The column physics code interface
----------------------------------------

Subroutine calls and other linkages into Icepack from the host model should only
need to access the **icepack\_intfc\*.F90** interface modules within the 
``columnphysics/`` directory.  
The Icepack driver in the ``configuration/driver/`` directory is based on the CICE
model and provides an example of the sea ice host model capabilities needed for inclusion
of Icepack.  In particular, host models will need to include code equivalent to that
in the modules **icedrv\_\*_column.F90**.  Calls into the Icepack interface routines
are primarily from **icedrv\_step\_mod.F90** but there are others (search the driver code
for ``intfc``).

Guiding principles for the creation of Icepack include the following: 
CHECK THAT THESE ARE TRUE

- The column physics modules shall be independent of all sea ice model infrastructural
  elements that may vary from model to model.  Examples include input/output, timers,
  references to CPUs or computational tasks, initialization other than that necessary for
  strictly physical reasons, and anything related to a horizontal grid.
- The column physics modules shall not call or reference any routines or code that 
  reside outside of the **columnphysics/** directory.
- Any capabilities required by a host sea ice model (e.g. calendar variables, tracer 
  flags, diagnostics) shall be implemented in the driver and passed into or out of the 
  column physics modules via array arguments.


Atmosphere and ocean boundary forcing
-------------------------------------

:ref:`tab-flux-cpl`: *Data exchanged between the CESM flux coupler and the sea ice model that are relevant to Icepack*  

.. _tab-flux-cpl:

.. csv-table:: Table 1
   :header: "Variable", "Description", "Interaction with flux coupler"
   :widths: 15, 15, 30
     
   ":math:`z_o`", "Atmosphere level height", "From *atmosphere model* via flux coupler **to** *sea ice model*"
   ":math:`\vec{U}_a`", "Wind velocity", "From *atmosphere model* via flux coupler **to** *sea ice model*"
   ":math:`Q_a`", "Specific humidity", "From *atmosphere model* via flux coupler **to** *sea ice model*"
   ":math:`\rho_a`", "Air density", "From *atmosphere model* via flux coupler **to** *sea ice model*"
   ":math:`\Theta_a`", "Air potential temperature", "From *atmosphere model* via flux coupler **to** *sea ice model*"
   ":math:`T_a`", "Air temperature", "From *atmosphere model* via flux coupler **to** *sea ice model*"
   ":math:`F_{sw\downarrow}`", "Incoming shortwave radiation (4 bands)", "From *atmosphere model* via flux coupler **to** *sea ice model*"
   ":math:`F_{L\downarrow}`", "Incoming longwave radiation", "From *atmosphere model* via flux coupler **to** *sea ice model*"
   ":math:`F_{rain}`", "Rainfall rate", "From *atmosphere model* via flux coupler **to** *sea ice model*"
   ":math:`F_{snow}`", "Snowfall rate", "From *atmosphere model* via flux coupler **to** *sea ice model*"
   ":math:`F_{frzmlt}`", "Freezing/melting potential", "From *ocean model* via flux coupler **to** *sea ice model*"
   ":math:`T_w`", "Sea surface temperature", "From *ocean model* via flux coupler **to** *sea ice model*"
   ":math:`S`", "Sea surface salinity", "From *ocean model* via flux coupler **to** *sea ice model*"
   ":math:`\vec{U}_w`", "Surface ocean currents", "From *ocean model* via flux coupler **to** *sea ice model* (available in Icepack driver, not used directly in column physics)"
   ":math:`\vec{\tau}_a`", "Wind stress", "From *sea ice model* via flux coupler **to** *atmosphere model*"
   ":math:`F_s`", "Sensible heat flux", "From *sea ice model* via flux coupler **to** *atmosphere model*"
   ":math:`F_l`", "Latent heat flux", "From *sea ice model* via flux coupler **to** *atmosphere model*"
   ":math:`F_{L\uparrow}`", "Outgoing longwave radiation", "From *sea ice model* via flux coupler **to** *atmosphere model*"
   ":math:`F_{evap}`", "Evaporated water", "From *sea ice model* via flux coupler **to** *atmosphere model*"
   ":math:`\alpha`", "Surface albedo (4 bands)", "From *sea ice model* via flux coupler **to** *atmosphere model*"
   ":math:`T_{sfc}`", "Surface temperature", "From *sea ice model* via flux coupler **to** *atmosphere model*"
   ":math:`F_{sw\Downarrow}`", "Penetrating shortwave radiation", "From *sea ice model* via flux coupler **to** *ocean model*"
   ":math:`F_{water}`", "Fresh water flux", "From *sea ice model* via flux coupler **to** *ocean model*"
   ":math:`F_{hocn}`", "Net heat flux to ocean", "From *sea ice model* via flux coupler **to** *ocean model*"
   ":math:`F_{salt}`", "Salt flux", "From *sea ice model* via flux coupler **to** *ocean model*"
   ":math:`\vec{\tau}_w`", "Ice-ocean stress", "From *sea ice model* via flux coupler **to** *ocean model*"
   ":math:`F_{bio}`", "Biogeochemical fluxes", "From *sea ice model* via flux coupler **to** *ocean model*"
   ":math:`a_{i}`", "Ice fraction", "From *sea ice model* via flux coupler **to** both *ocean and atmosphere models*"
   ":math:`T^{ref}_{a}`", "2m reference temperature (diagnostic)", "From *sea ice model* via flux coupler **to** both *ocean and atmosphere models*"
   ":math:`Q^{ref}_{a}`", "2m reference humidity (diagnostic)", "From *sea ice model* via flux coupler **to** both *ocean and atmosphere models*"
   ":math:`F_{swabs}`", "Absorbed shortwave (diagnostic)", "From *sea ice model* via flux coupler **to** both *ocean and atmosphere models*"


The ice fraction :math:`a_i` (aice) is the total fractional ice
coverage of a grid cell. That is, in each cell,

.. math::
   \begin{array}{cl}
                  a_{i}=0 & \mbox{if there is no ice} \\ 
                  a_{i}=1 & \mbox{if there is no open water} \\ 
                  0<a_{i}<1 & \mbox{if there is both ice and open water,}
   \end{array}

where :math:`a_{i}` is the sum of fractional ice areas for each category
of ice. The ice fraction is used by the flux coupler to merge fluxes
from the ice model with fluxes from the other components. For example,
the penetrating shortwave radiation flux, weighted by :math:`a_i`, is
combined with the net shortwave radiation flux through ice-free leads,
weighted by (:math:`1-a_i`), to obtain the net shortwave flux into the
ocean over the entire grid cell. The CESM flux coupler requires the fluxes to
be divided by the total ice area so that the ice and land models are
treated identically (land also may occupy less than 100% of an
atmospheric grid cell). These fluxes are "per unit ice area" rather than
"per unit grid cell area."

In some coupled climate models (for example, recent versions of the U.K.
Hadley Centre model) the surface air temperature and fluxes are computed
within the atmosphere model and are passed to CICE for use in the column physics. In this case the
logical parameter ``calc_Tsfc`` in *ice_therm_vertical* is set to false.
The fields ``fsurfn`` (the net surface heat flux from the atmosphere), ``flatn``
(the surface latent heat flux), and ``fcondtopn`` (the conductive flux at
the top surface) for each ice thickness category are copied or derived
from the input coupler fluxes and are passed to the thermodynamic driver
subroutine, *thermo_vertical*. At the end of the time step, the surface
temperature and effective conductivity (i.e., thermal conductivity
divided by thickness) of the top ice/snow layer in each category are
returned to the atmosphere model via the coupler. Since the ice surface
temperature is treated explicitly, the effective conductivity may need
to be limited to ensure stability. As a result, accuracy may be
significantly reduced, especially for thin ice or snow layers. A more
stable and accurate procedure would be to compute the temperature
profiles for both the atmosphere and ice, together with the surface
fluxes, in a single implicit calculation. This was judged impractical,
however, given that the atmosphere and sea ice models generally exist on
different grids and/or processor sets.

.. _atmo:

Atmosphere
~~~~~~~~~~

The wind velocity, specific humidity, air density and potential
temperature at the given level height :math:`z_\circ` are used to
compute transfer coefficients used in formulas for the surface wind
stress and turbulent heat fluxes :math:`\vec\tau_a`, :math:`F_s`, and
:math:`F_l`, as described below. The sensible and latent heat fluxes,
:math:`F_s` and :math:`F_l`, along with shortwave and longwave
radiation, :math:`F_{sw\downarrow}`, :math:`F_{L\downarrow}`
and :math:`F_{L\uparrow}`, are included in the flux balance that
determines the ice or snow surface temperature when calc\_Tsfc = true.
As described in the :ref:`thermo` section, these fluxes depend nonlinearly
on the ice surface temperature :math:`T_{sfc}`. The balance
equation is iterated until convergence, and the resulting fluxes and
:math:`T_{sfc}` are then passed to the flux coupler.

The snowfall precipitation rate (provided as liquid water equivalent and
converted by the ice model to snow depth) also contributes to the heat
and water mass budgets of the ice layer. Melt ponds generally form on
the ice surface in the Arctic and refreeze later in the fall, reducing
the total amount of fresh water that reaches the ocean and altering the
heat budget of the ice; this version includes two new melt pond
parameterizations. Rain and all melted snow end up in the ocean.

Wind stress and transfer coefficients for the
turbulent heat fluxes are computed in subroutine
*atmo\_boundary\_layer* following :cite:`KL02`. For
clarity, the equations are reproduced here in the present notation.

The wind stress and turbulent heat flux calculation accounts for both
stable and unstable atmosphere–ice boundary layers. Define the
"stability"

.. math::
   \Upsilon = {\kappa g z_\circ\over u^{*2}}
   \left({\Theta^*\over\Theta_a\left(1+0.606Q_a\right)}  +
   {Q^*\over 1/0.606 + Q_a}\right),
   :label: upsilon

where :math:`\kappa` is the von Karman constant, :math:`g` is
gravitational acceleration, and :math:`u^*`, :math:`\Theta^*` and
:math:`Q^*` are turbulent scales for velocity, temperature, and humidity,
respectively:

.. math::
   \begin{aligned}
   u^*&=&c_u \left|\vec{U}_a\right|, \\
   \Theta^*&=& c_\theta\left(\Theta_a-T_{sfc}\right), \\
   Q^*&=&c_q\left(Q_a-Q_{sfc}\right).\end{aligned}
   :label: stars

The wind speed has a minimum value of 1 m/s. We have ignored ice motion
in :math:`u^*`, and :math:`T_{sfc}` and
:math:`Q_{sfc}` are the surface temperature and specific
humidity, respectively. The latter is calculated by assuming a saturated
surface, as described in the :ref:`sfc-forcing` section.

Neglecting form drag,the exchange coefficients :math:`c_u`,
:math:`c_\theta` and :math:`c_q` are initialized as

.. math:: 
   \kappa\over \ln(z_{ref}/z_{ice})
   :label: kappa

and updated during a short iteration, as they depend upon the turbulent
scales. The number of iterations is set by the namelist variable
``natmiter``. (For the case with form drag, see the :ref:`formdrag` section.)
Here, :math:`z_{ref}` is a reference height of 10m and
:math:`z_{ice}` is the roughness length scale for the given
sea ice category. :math:`\Upsilon` is constrained to have magnitude less
than 10. Further, defining
:math:`\chi = \left(1-16\Upsilon\right)^{0.25}` and :math:`\chi \geq 1`,
the "integrated flux profiles" for momentum and stability in the
unstable (:math:`\Upsilon <0`) case are given by

.. math::
   \begin{aligned}
   \psi_m = &\mbox{}&2\ln\left[0.5(1+\chi)\right] +
            \ln\left[0.5(1+\chi^2)\right] -2\tan^{-1}\chi +
            {\pi\over 2}, \\
   \psi_s = &\mbox{}&2\ln\left[0.5(1+\chi^2)\right].\end{aligned}
   :label: psi1

In a departure from the parameterization used in
:cite:`KL02`, we use profiles for the stable case
following :cite:`JAM99`,

.. math::
   \psi_m = \psi_s = -\left[0.7\Upsilon + 0.75\left(\Upsilon-14.3\right)
            \exp\left(-0.35\Upsilon\right) + 10.7\right].
   :label: psi2

The coefficients are then updated as

.. math::
   \begin{aligned}
   c_u^\prime&=&{c_u\over 1+c_u\left(\lambda-\psi_m\right)/\kappa} \\
   c_\theta^\prime&=& {c_\theta\over 1+c_\theta\left(\lambda-\psi_s\right)/\kappa}\\
   c_q^\prime&=&c_\theta^\prime\end{aligned}
   :label: coeff1

where :math:`\lambda = \ln\left(z_\circ/z_{ref}\right)`. The
first iteration ends with new turbulent scales from
equations :eq:`stars`. After five iterations the latent and sensible
heat flux coefficients are computed, along with the wind stress:

.. math::
   \begin{aligned}
   C_l&=&\rho_a \left(L_{vap}+L_{ice}\right) u^* c_q \\
   C_s&=&\rho_a c_p u^* c_\theta^* + 1, \\
   \vec{\tau}_a&=&{\rho_a u^{*2}\vec{U}_a\over |\vec{U}_a|},\end{aligned}
   :label: coeff2

where :math:`L_{vap}` and :math:`L_{ice}` are
latent heats of vaporization and fusion, :math:`\rho_a` is the density
of air and :math:`c_p` is its specific heat. Again following
:cite:`JAM99`, we have added a constant to the sensible
heat flux coefficient in order to allow some heat to pass between the
atmosphere and the ice surface in stable, calm conditions.

The atmospheric reference temperature :math:`T_a^{ref}` is computed from
:math:`T_a` and :math:`T_{sfc}` using the coefficients
:math:`c_u`, :math:`c_\theta` and :math:`c_q`. Although the sea ice
model does not use this quantity, it is convenient for the ice model to
perform this calculation. The atmospheric reference temperature is
returned to the flux coupler as a climate diagnostic. The same is true
for the reference humidity, :math:`Q_a^{ref}`.

Additional details about the latent and sensible heat fluxes and other
quantities referred to here can be found in
the :ref:`sfc-forcing` section.

.. _ocean:

Ocean
~~~~~~

New sea ice forms when the ocean temperature drops below its freezing
temperature. In the Bitz and Lipscomb thermodynamics,
:cite:`BL99` :math:`T_f=-\mu S`, where :math:`S` is the
seawater salinity and :math:`\mu=0.054 \ ^\circ`/ppt is the ratio of the
freezing temperature of brine to its salinity (linear liquidus
approximation). For the mushy thermodynamics, :math:`T_f` is given by a
piecewise linear liquidus relation. The ocean model calculates the new
ice formation; if the freezing/melting potential
:math:`F_{frzmlt}` is positive, its value represents a certain
amount of frazil ice that has formed in one or more layers of the ocean
and floated to the surface. (The ocean model assumes that the amount of
new ice implied by the freezing potential actually forms.)

If :math:`F_{frzmlt}` is negative, it is used to heat already
existing ice from below. In particular, the sea surface temperature and
salinity are used to compute an oceanic heat flux :math:`F_w`
(:math:`\left|F_w\right| \leq \left|F_{frzmlt}\right|`) which
is applied at the bottom of the ice. The portion of the melting
potential actually used to melt ice is returned to the coupler in
:math:`F_{hocn}`. The ocean model adjusts its own heat budget
with this quantity, assuming that the rest of the flux remained in the
ocean.

In addition to runoff from rain and melted snow, the fresh water flux
:math:`F_{water}` includes ice melt water from the top surface
and water frozen (a negative flux) or melted at the bottom surface of
the ice. This flux is computed as the net change of fresh water in the
ice and snow volume over the coupling time step, excluding frazil ice
formation and newly accumulated snow. Setting the namelist option
update\_ocn\_f to true causes frazil ice to be included in the fresh
water and salt fluxes.

There is a flux of salt into the ocean under melting conditions, and a
(negative) flux when sea water is freezing. However, melting sea ice
ultimately freshens the top ocean layer, since the ocean is much more
saline than the ice. The ice model passes the net flux of salt
:math:`F_{salt}` to the flux coupler, based on the net change
in salt for ice in all categories. In the present configuration,
ice\_ref\_salinity is used for computing the salt flux, although the ice
salinity used in the thermodynamic calculation has differing values in
the ice layers.

A fraction of the incoming shortwave :math:`F_{sw\Downarrow}`
penetrates the snow and ice layers and passes into the ocean, as
described in the :ref:`sfc-forcing` section.

CHECK icepack\_ocean.F90?

A thermodynamic slab ocean mixed-layer parameterization is available 
in **icepack\_ocean.F90** and can be run in the full CICE configuration.
The turbulent fluxes are computed above the water surface using the same
parameterizations as for sea ice, but with parameters appropriate for
the ocean. The surface flux balance takes into account the turbulent
fluxes, oceanic heat fluxes from below the mixed layer, and shortwave
and longwave radiation, including that passing through the sea ice into
the ocean. If the resulting sea surface temperature falls below the
salinity-dependent freezing point, then new ice (frazil) forms.
Otherwise, heat is made available for melting the ice.

.. _formdrag:

Variable exchange coefficients
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

In the default configuration, atmospheric and oceanic neutral drag
coefficients (:math:`c_u` and :math:`c_w`) are assumed constant in time
and space. These constants are chosen to reflect friction associated
with an effective sea ice surface roughness at the ice–atmosphere and
ice–ocean interfaces. Sea ice (in both Arctic and Antarctic) contains
pressure ridges as well as floe and melt pond edges that act as discrete
obstructions to the flow of air or water past the ice, and are a source
of form drag. Following :cite:`TFSFFKLB14` and based on
recent theoretical developments :cite:`LGHA12,LLCL11`, the
neutral drag coefficients can now be estimated from properties of the
ice cover such as ice concentration, vertical extent and area of the
ridges, freeboard and floe draft, and size of floes and melt ponds. The
new parameterization allows the drag coefficients to be coupled to the
sea ice state and therefore to evolve spatially and temporally. This
parameterization is contained in the subroutine *neutral\_drag\_coeffs*
and is accessed by setting `formdrag` = true in the namelist.

Following :cite:`TFSFFKLB14`, consider the general case of
fluid flow obstructed by N randomly oriented obstacles of height
:math:`H` and transverse length :math:`L_y`, distributed on a domain
surface area :math:`S_T`. Under the assumption of a logarithmic fluid
velocity profile, the general formulation of the form drag coefficient
can be expressed as

.. math:: 
   C_d=\frac{N c S_c^2 \gamma L_y  H}{2 S_T}\left[\frac{\ln(H/z_0)}{\ln(z_{ref}/z_0)}\right]^2,
   :label: formdrag

where :math:`z_0` is a roughness length parameter at the top or bottom
surface of the ice, :math:`\gamma` is a geometric factor, :math:`c` is
the resistance coefficient of a single obstacle, and :math:`S_c` is a
sheltering function that takes into account the shielding effect of the
obstacle,

.. math:: 
   S_{c}=\left(1-\exp(-s_l D/H)\right)^{1/2},
   :label: shelter

with :math:`D` the distance between two obstacles and :math:`s_l` an
attenuation parameter.

As in the original drag formulation in CICE (:ref:`atmo` and
:ref:`ocean` sections), :math:`c_u` and :math:`c_w` along with the transfer
coefficients for sensible heat, :math:`c_{\theta}`, and latent heat,
:math:`c_{q}`, are initialized to a situation corresponding to neutral
atmosphere–ice and ocean–ice boundary layers. The corresponding neutral
exchange coefficients are then replaced by coefficients that explicitly
account for form drag, expressed in terms of various contributions as

.. math::
   \tt{Cdn\_atm}  = \tt{Cdn\_atm\_rdg} + \tt{Cdn\_atm\_floe} + \tt{Cdn\_atm\_skin} + \tt{Cdn\_atm\_pond} ,
   :label: Cda

.. math::
   \tt{Cdn\_ocn}  =  \tt{Cdn\_ocn\_rdg} + \tt{Cdn\_ocn\_floe} + \tt{Cdn\_ocn\_skin}. 
   :label: Cdw

The contributions to form drag from ridges (and keels underneath the
ice), floe edges and melt pond edges can be expressed using the general
formulation of equation :eq:`formdrag` (see :cite:`TFSFFKLB14` for
details). Individual terms in equation :eq:`Cdw` are fully described in
:cite:`TFSFFKLB14`. Following :cite:`Arya75`
the skin drag coefficient is parametrized as

.. math:: 
   { \tt{Cdn\_(atm/ocn)\_skin}}=a_{i} \left(1-m_{(s/k)} \frac{H_{(s/k)}}{D_{(s/k)}}\right)c_{s(s/k)}, \mbox{       if  $\displaystyle\frac{H_{(s/k)}}{D_{(s/k)}}\ge\frac{1}{m_{(s/k)}}$,}
   :label: skindrag

where :math:`m_s` (:math:`m_k`) is a sheltering parameter that depends
on the average sail (keel) height, :math:`H_s` (:math:`H_k`), but is
often assumed constant, :math:`D_s` (:math:`D_k`) is the average
distance between sails (keels), and :math:`c_{ss}` (:math:`c_{sk}`) is
the unobstructed atmospheric (oceanic) skin drag that would be attained
in the absence of sails (keels) and with complete ice coverage,
:math:`a_{ice}=1`.

Calculation of equations :eq:`formdrag` – :eq:`skindrag` requires that small-scale geometrical
properties of the ice cover be related to average grid cell quantities
already computed in the sea ice model. These intermediate quantities are
briefly presented here and described in more detail in
:cite:`TFSFFKLB14`. The sail height is given by

.. math:: 
   H_{s} = \displaystyle 2\frac{v_{rdg}}{a_{rdg}}\left(\frac{\alpha\tan \alpha_{k} R_d+\beta \tan \alpha_{s} R_h}{\phi_r\tan \alpha_{k} R_d+\phi_k \tan \alpha_{s} R_h^2}\right),
   :label: Hs

and the distance between sails\ 

.. math:: 
   D_{s} = \displaystyle 2 H_s\frac{a_{i}}{a_{rdg}} \left(\frac{\alpha}{\tan \alpha_s}+\frac{\beta}{\tan \alpha_k}\frac{R_h}{R_d}\right),
   :label: Ds

where :math:`0<\alpha<1` and :math:`0<\beta<1` are weight functions,
:math:`\alpha_{s}` and :math:`\alpha_{k}` are the sail and keel slope,
:math:`\phi_s` and :math:`\phi_k` are constant porosities for the sails
and keels, and we assume constant ratios for the average keel depth and
sail height (:math:`H_k/H_s=R_h`) and for the average distances between
keels and between sails (:math:`D_k/D_s=R_d`). With the assumption of
hydrostatic equilibrium, the effective ice plus snow freeboard is
:math:`H_{f}=\bar{h_i}(1-\rho_i/\rho_w)+\bar{h_s}(1-\rho_s/\rho_w)`,
where :math:`\rho_i`, :math:`\rho_w` and :math:`\rho_s` are
respectively the densities of sea ice, water and snow, :math:`\bar{h_i}`
is the mean ice thickness and :math:`\bar{h_s}` is the mean snow
thickness (means taken over the ice covered regions). For the melt pond
edge elevation we assume that the melt pond surface is at the same level
as the ocean surface surrounding the floes
:cite:`FF07,FFT10,FSFH12` and use the simplification
:math:`H_p = H_f`. Finally to estimate the typical floe size
:math:`L_A`, distance between floes, :math:`D_F`, and melt pond size,
:math:`L_P` we use the parameterizations of :cite:`LGHA12`
to relate these quantities to the ice and pond concentrations. All of
these intermediate quantities are available for output, along
with ``Cdn_atm``, ``Cdn_ocn`` and the ratio ``Cdn_atm_ratio_n`` between the
total atmospheric drag and the atmospheric neutral drag coefficient.

We assume that the total neutral drag coefficients are thickness
category independent, but through their dependance on the diagnostic
variables described above, they vary both spatially and temporally. The
total drag coefficients and heat transfer coefficients will also depend
on the type of stratification of the atmosphere and the ocean, and we
use the parameterization described in the :ref:`atmo` section that accounts
for both stable and unstable atmosphere–ice boundary layers. In contrast
to the neutral drag coefficients the stability effect of the atmospheric
boundary layer is calculated separately for each ice thickness category.

The transfer coefficient for oceanic heat flux to the bottom of the ice
may be varied based on form drag considerations by setting the namelist
variable ``fbot_xfer_type`` to ``Cdn_ocn``; this is recommended when using
the form drag parameterization. Its default value of the transfer
coefficient is 0.006 (``fbot_xfer_type = ’constant’``).


.. _model_comp:

Model components
================

The Arctic and Antarctic sea ice packs are mixtures of open water, thin
first-year ice, thicker multiyear ice, and thick pressure ridges. The
thermodynamic and dynamic properties of the ice pack depend on how much
ice lies in each thickness range. Thus the basic problem in sea ice
modeling is to describe the evolution of the ice thickness distribution
(ITD) in time and space.

The fundamental equation solved by CICE is :cite:`TRMC75`:

.. math::
   \frac{\partial g}{\partial t} = -\nabla \cdot (g {\bf u}) 
    - \frac{\partial}{\partial h} (f g) + \psi - L,
   :label: transport-g

where :math:`{\bf u}` is the horizontal ice velocity,
:math:`\nabla = (\frac{\partial}{\partial x}, \frac{\partial}{\partial y})`,
:math:`f` is the rate of thermodynamic ice growth, :math:`\psi` is a
ridging redistribution function, 
:math:`L` is the lateral melt rate
and :math:`g` is the ice thickness
distribution function. We define :math:`g({\bf x},h,t)\,dh` as the
fractional area covered by ice in the thickness range :math:`(h,h+dh)`
at a given time and location.  Icepack represents all of the terms in this
equation except for the divergence (the first term on the right).

Equation :eq:`transport-g` is solved by partitioning the ice pack in
each grid cell into discrete thickness categories. The number of
categories can be set by the user, with a default value :math:`N_C = 5`.
(Five categories, plus open water, are generally sufficient to simulate
the annual cycles of ice thickness, ice strength, and surface fluxes
:cite:`BHWE01,Lipscomb01`.) Each category :math:`n` has
lower thickness bound :math:`H_{n-1}` and upper bound :math:`H_n`. The
lower bound of the thinnest ice category, :math:`H_0`, is set to zero.
The other boundaries are chosen with greater resolution for small
:math:`h`, since the properties of the ice pack are especially sensitive
to the amount of thin ice :cite:`Maykut82`. The continuous
function :math:`g(h)` is replaced by the discrete variable
:math:`a_{in}`, defined as the fractional area covered by ice in the
open water by :math:`a_{i0}`, giving :math:`\sum_{n=0}^{N_C} a_{in} = 1`
by definition.

Category boundaries are computed in *init\_itd* using one of several
formulas, summarized in :ref:`tab-itd`. 
Setting the namelist variable ``kcatbound`` equal to 0 or 1 gives lower 
thickness boundaries for any number of thickness categories :math:`N_C`.
:ref:`tab-itd` shows the boundary values for :math:`N_C` = 5 and linear remapping 
of the ice thickness distribution. A third option specifies the boundaries 
based on the World Meteorological Organization classification; the full WMO
thickness distribution is used if :math:`N_C` = 7; if :math:`N_C` = 5 or
6, some of the thinner categories are combined. The original formula
(``kcatbound`` = 0) is the default. Category boundaries differ from those
shown in :ref:`tab-itd` for the delta-function ITD. Users may
substitute their own preferred boundaries in *init\_itd*.

:ref:`tab-itd` : *Lower boundary values for thickness categories, in meters, for 
the three distribution options (* ``kcatbound`` *) and linear remapping (* `kitd` = 1 *). 
In the WMO case, the distribution used depends on the number of categories used.*

.. _tab-itd:

.. table:: Table 2 

   +----------------+------------+---------+--------+--------+--------+
   | distribution   | original   | round   |           WMO            |
   +================+============+=========+========+========+========+
   | `kcatbound`    | 0          | 1       |            2             |
   +----------------+------------+---------+--------+--------+--------+
   | :math:`N_C`    | 5          | 5       | 5      | 6      | 7      |
   +----------------+------------+---------+--------+--------+--------+
   | categories     |             lower bound (m)                     |
   +----------------+------------+---------+--------+--------+--------+
   | 1              | 0.00       | 0.00    | 0.00   | 0.00   | 0.00   |
   +----------------+------------+---------+--------+--------+--------+
   | 2              | 0.64       | 0.60    | 0.30   | 0.15   | 0.10   |
   +----------------+------------+---------+--------+--------+--------+
   | 3              | 1.39       | 1.40    | 0.70   | 0.30   | 0.15   |
   +----------------+------------+---------+--------+--------+--------+
   | 4              | 2.47       | 2.40    | 1.20   | 0.70   | 0.30   |
   +----------------+------------+---------+--------+--------+--------+
   | 5              | 4.57       | 3.60    | 2.00   | 1.20   | 0.70   |
   +----------------+------------+---------+--------+--------+--------+
   | 6              |            |         |        | 2.00   | 1.20   |
   +----------------+------------+---------+--------+--------+--------+
   | 7              |            |         |        |        | 2.00   |
   +----------------+------------+---------+--------+--------+--------+

.. _tracers:

Tracers
-------

Numerous tracers are available with the column physics.  Several of these are 
required (surface temperature and thickness, salinity and enthalpy of ice and snow layers),
and many others are options.  For instance, there are tracers to track the age of the ice;
the area of first-year ice, fractions of ice area and volume that are level, from which
the amount of deformed ice can be calculated; pond area, volume and ice-covered volume;
aerosols and numerous other biogeochemical tracers.

.. _pondtr:

Tracers that depend on other tracers 
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Tracers may be defined that depend on other tracers. Melt pond tracers
provide an example (these equations pertain to cesm and topo tracers;
level-ice tracers are similar with an extra factor of :math:`a_{lvl}`,
see Equations :eq:`transport-lvl`–:eq:`transport-ipnd-lvl`. Conservation
equations for pond area fraction :math:`a_{pnd}a_i` and pond volume
:math:`h_{pnd}a_{pnd}a_i`, given the ice velocity :math:`\bf u`, are

.. math::
   {\partial\over\partial t} (a_{pnd}a_{i}) + \nabla \cdot (a_{pnd}a_{i} {\bf u}) = 0,
   :label: transport-apnd

.. math::
   {\partial\over\partial t} (h_{pnd}a_{pnd}a_{i}) + \nabla \cdot (h_{pnd}a_{pnd}a_{i} {\bf u}) = 0.
   :label: transport-hpnd

(These equations represent quantities within one thickness category;
all melt pond calculations are performed for each category, separately.)
Equation :eq:`transport-hpnd` expresses conservation of melt pond
volume, but in this form highlights that the quantity tracked in the
code is the pond depth tracer :math:`h_{pnd}`, which depends on the pond
area tracer :math:`a_{pnd}`. Likewise, :math:`a_{pnd}` is a tracer on
ice area (Equation :eq:`transport-apnd`), which is a state variable, not a
tracer.

For a generic quantity :math:`q` that represents a mean value over the
ice fraction, :math:`q a_i` is the average value over the grid cell.
Thus for cesm or topo melt ponds, :math:`h_{pnd}` can be considered the
actual pond depth, :math:`h_{pnd}a_{pnd}` is the mean pond depth over
the sea ice, and :math:`h_{pnd}a_{pnd}a_i` is the mean pond depth over
the grid cell. These quantities are illustrated in :ref:`fig-tracers`.

.. _fig-tracers:

.. figure:: ./figures/tracergraphic.png
   :align: center
   :scale: 50%  

   Figure 1

:ref:`fig-tracers` : Melt pond tracer definitions. The graphic on the right
illustrates the *grid cell* fraction of ponds or level ice as defined
by the tracers. The chart on the left provides corresponding ice
thickness and pond depth averages over the grid cell, sea ice and
pond area fractions. 

Tracers may need to be modified for physical reasons outside of the
"core" module or subroutine describing their evolution. For example,
when new ice forms in open water, the new ice does not yet have ponds on
it. Likewise when sea ice deforms, we assume that pond water (and ice)
on the portion of ice that ridges is lost to the ocean.

When new ice is added to a grid cell, the *grid cell* total area of melt
ponds is preserved within each category gaining ice,
:math:`a_{pnd}^{t+\Delta t}a_{i}^{t+\Delta t} = a_{pnd}^{t}a_{i}^{t}`, 
or

.. math::
   a_{pnd}^{t+\Delta t}= {a_{pnd}^{t}a_{i}^{t} \over a_{i}^{t+\Delta t} }.
   :label: apnd

Similar calculations are performed for all tracer types, for example
tracer-on-tracer dependencies such as :math:`h_{pnd}`, when needed:

.. math:: 
   h_{pnd}^{t+\Delta t}= {h_{pnd}^{t}a_{pnd}^{t}a_{i}^{t} \over a_{pnd}^{t+\Delta t}a_{i}^{t+\Delta t} }.
   :label: hpnd

In this case (adding new ice), :math:`h_{pnd}` does not change because
:math:`a_{pnd}^{t+\Delta t}a_{i}^{t+\Delta t} = a_{pnd}^{t}a_{i}^{t}`.

When ice is transferred between two thickness categories, we conserve
the total pond area summed over categories :math:`n`,

.. math:: 
   \sum_n a_{pnd}^{t+\Delta t}(n)a_{i}^{t+\Delta t}(n) = \sum_n a_{pnd}^{t}(n)a_{i}^{t}(n).
   :label: apnd2

Thus,

.. math::
   a_{pnd}^{t+\Delta t}(m) &= {\sum_n a_{pnd}^{t}(n)a_{i}^{t}(n) - \sum_{n\ne m} a_{pnd}^{t+\Delta t}(n)a_{i}^{t+\Delta t}(n) \over a_i^{t+\Delta t}(m)  } \\
   &= {a_{pnd}^t(m)a_i^t(m) + \sum_{n\ne m} \Delta \left(a_{pnd}a_i\right)^{t+\Delta t} \over a_i^{t+\Delta t}(m)  }
   :label: apnd3

This is more complicated because of the :math:`\Delta` term on the
right-hand side, which is handled in subroutine *icepack\_compute\_tracers*. Such
tracer calculations are scattered throughout the code, wherever there
are changes to the ice thickness distribution.

Note that if a quantity such as :math:`a_{pnd}` becomes zero in a grid
cell’s thickness category, then all tracers that depend on it also
become zero. If a tracer should be conserved (e.g., aerosols and the
liquid water in topo ponds), additional code must be added to track
changes in the conserved quantity.

More information about the melt pond schemes is in the
:ref:`ponds` section.

.. _ice-age:

Ice age
~~~~~~~

The age of the ice, :math:`\tau_{age}`, is treated as an
ice-volume tracer (`trcr\_depend` = 1). It is initialized at 0 when ice
forms as frazil, and the ice ages the length of the timestep during each
timestep. Freezing directly onto the bottom of the ice does not affect
the age, nor does melting. Mechanical redistribution processes and
advection alter the age of ice in any given grid cell in a conservative
manner following changes in ice area. The sea ice age tracer is
validated in :cite:`HB09`.

Another age-related tracer, the area covered by first-year ice
:math:`a_{FY}`, is an area tracer (`trcr\_depend` = 0) that corresponds
more closely to satellite-derived ice age data for first-year ice than
does :math:`\tau_{age}`. It is re-initialized each year on 15
September (``yday`` = 259) in the northern hemisphere and 15 March (``yday`` =
75) in the southern hemisphere, in non-leap years. This tracer is
increased when new ice forms in open water, in subroutine
*add\_new\_ice* in **icepack\_therm\_itd.F90**. The first-year area tracer
is discussed in :cite:`ABTH11`.

.. _itd-trans:

Transport in thickness space
----------------------------

Next we solve the equation for ice transport in thickness space due to
thermodynamic growth and melt,

.. math::
   \frac{\partial g}{\partial t} + \frac{\partial}{\partial h} (f g) = 0,
   :label: itd-transport

which is obtained from Equation :eq:`transport-g` by neglecting the first and
third terms on the right-hand side. We use the remapping method of
:cite:`Lipscomb01`, in which thickness categories are
represented as Lagrangian grid cells whose boundaries are projected
forward in time. The thickness distribution function :math:`g` is
approximated as a linear function of :math:`h` in each displaced
category and is then remapped onto the original thickness categories.
This method is numerically smooth and is not too diffusive. It can be
viewed as a 1D simplification of the 2D incremental remapping scheme
described above.

We first compute the displacement of category boundaries in thickness
space. Assume that at time :math:`m` the ice areas :math:`a_n^m` and
mean ice thicknesses :math:`h_n^m` are known for each thickness
category. (For now we omit the subscript :math:`i` that distinguishes
ice from snow.) We use a thermodynamic model (:ref:`thermo`)
to compute the new mean thicknesses :math:`h_n^{m+1}` at time
:math:`m+1`. The time step must be small enough that trajectories do not
cross; i.e., :math:`h_n^{m+1} < h_{n+1}^{m+1}` for each pair of adjacent
categories. The growth rate at :math:`h = h_n` is given by
:math:`f_n = (h_n^{m+1} - h_n^m) / \Delta t`. By linear interpolation we
estimate the growth rate :math:`F_n` at the upper category boundary
:math:`H_n`:

.. math:: 
   F_n = f_n + \frac{f_{n+1}-f_n}{h_{n+1}-h_n} \, (H_n - h_n).
   :label: growth-rate

If :math:`a_n` or :math:`a_{n+1} = 0`, :math:`F_n` is set to the growth
rate in the nonzero category, and if :math:`a_n = a_{n+1} = 0`, we set
:math:`F_n = 0`. The temporary displaced boundaries are given by

.. math:: 
   H_n^* = H_n + F_n \, \Delta t, \ n = 1 \ {\rm to} \ N-1
   :label: displ

The boundaries must not be displaced by more than one category to the
left or right; that is, we require :math:`H_{n-1} < H_n^* < H_{n+1}`.
Without this requirement we would need to do a general remapping rather
than an incremental remapping, at the cost of added complexity.

Next we construct :math:`g(h)` in the displaced thickness categories.
The ice areas in the displaced categories are :math:`a_n^{m+1} = a_n^m`,
since area is conserved following the motion in thickness space (i.e.,
during vertical ice growth or melting). The new ice volumes are
:math:`v_n^{m+1} = (a_n h_n)^{m+1} = a_n^m h_n^{m+1}`. For conciseness,
define :math:`H_L = H_{n-1}^*` and :math:`H_R = H_{n}^*` and drop the
time index :math:`m+1`. We wish to construct a continuous function
:math:`g(h)` within each category such that the total area and volume at
time :math:`m+1` are :math:`a_n` and :math:`v_n`, respectively:

.. math::
   \int_{H_L}^{H_R} g \, dh = a_n,
   :label: area-cons

.. math::
   \int_{H_L}^{H_R} h \, g \, dh = v_n.
   :label: volume-cons

The simplest polynomial that can satisfy both equations is a line. It
is convenient to change coordinates, writing
:math:`g(\eta) = g_1 \eta + g_0`, where :math:`\eta = h - H_L` and the
coefficients :math:`g_0` and :math:`g_1` are to be determined. Then
Equations :eq:`area-cons` and :eq:`volume-cons` can be written as

.. math:: 
   g_1 \frac{\eta_R^2}{2} + g_0 \eta_R = a_n,
  :label: g1

.. math:: 
   g_1 \frac{\eta_R^3}{3} + g_0 \frac{\eta_R^2}{2} = a_n \eta_n,
   :label: g1a

where :math:`\eta_R = H_R - H_L` and :math:`\eta_n = h_n - H_L`. These
equations have the solution

.. math::
   g_0 = \frac{6 a_n}{\eta_R^2} \left(\frac{2 \eta_R}{3} - \eta_n\right),
   :label: g0

.. math::
   g_1 = \frac{12 a_n}{\eta_R^3} \left(\eta_n - \frac{\eta_R}{2}\right).
   :label: g1b

Since :math:`g` is linear, its maximum and minimum values lie at the
boundaries, :math:`\eta = 0` and :math:`\eta_R`:

.. math::
   g(0)=\frac{6 a_n}{\eta_R^2} \, \left(\frac{2 \eta_R}{3} - \eta_n\right) = g_0,
   :label: gmin
 
.. math::
   g(\eta_R) = \frac{6 a_n}{\eta_R^2} \, \left(\eta_n - \frac{\eta_R}{3}\right).
   :label: gmax

Equation :eq:`gmin` implies that :math:`g(0) < 0` when
:math:`\eta_n > 2 \eta_R/3`, i.e., when :math:`h_n` lies in the right
third of the thickness range :math:`(H_L, H_R)`. Similarly, Equation :eq:`gmax`
implies that :math:`g(\eta_R) < 0` when :math:`\eta_n < \eta_R/3`, i.e.,
when :math:`h_n` is in the left third of the range. Since negative
values of :math:`g` are unphysical, a different solution is needed when
:math:`h_n` lies outside the central third of the thickness range. If
:math:`h_n` is in the left third of the range, we define a cutoff
thickness, :math:`H_C = 3 h_n - 2 H_L`, and set :math:`g = 0` between
:math:`H_C` and :math:`H_R`. Equations :eq:`g0` and :eq:`g1` are then
valid with :math:`\eta_R` redefined as :math:`H_C - H_L`. And if
:math:`h_n` is in the right third of the range, we define
:math:`H_C = 3 h_n - 2 H_R` and set :math:`g = 0` between :math:`H_L`
and :math:`H_C`. In this case, :eq:`g0` and :eq:`g1` apply with
:math:`\eta_R = H_R - H_C` and :math:`\eta_n = h_n - H_C`.

:ref:`fig-gplot` illustrates the linear reconstruction of :math:`g`
for the simple cases :math:`H_L = 0`, :math:`H_R = 1`, :math:`a_n = 1`,
and :math:`h_n =` 0.2, 0.4, 0.6, and 0.8. Note that :math:`g` slopes
downward (:math:`g_1 < 0`) when :math:`h_n` is less than the midpoint
thickness, :math:`(H_L + H_R)/2 = 1/2`, and upward when :math:`h_n`
exceeds the midpoint thickness. For :math:`h_n = 0.2` and 0.8,
:math:`g = 0` over part of the range.

.. _fig-gplot:

.. figure:: ./figures/gplot.png
   :align: center
   :scale: 20%

   Figure 4

:ref:`fig-gplot` : Linear approximation of the thickness distribution
function :math:`g(h)` for an ice category with left boundary
:math:`H_L = 0`, right boundary :math:`H_R = 1`, fractional area
:math:`a_n = 1`, and mean ice thickness :math:`h_n = 0.2, 0.4, 0.6,` and :math:`0.8`.

Finally, we remap the thickness distribution to the original boundaries
by transferring area and volume between categories. We compute the ice
area :math:`\Delta a_n` and volume :math:`\Delta v_n` between each
original boundary :math:`H_n` and displaced boundary :math:`H_n^*`. If
:math:`H_n^* > H_n`, ice moves from category :math:`n` to :math:`n+1`.
The area and volume transferred are

.. math::
   \Delta a_n = \int_{H_n}^{H_n^*} g \, dh,
   :label: move-area

.. math::
   \Delta v_n = \int_{H_n}^{H_n^*} h \, g \, dh.
   :label: move-volume

If :math:`H_n^* < H_N`, ice area and volume are transferred from
category :math:`n+1` to :math:`n` using Equations :eq:`move-area` and
:eq:`move-volume` with the limits of integration reversed. To evaluate
the integrals we change coordinates from :math:`h` to
:math:`\eta = h - H_L`, where :math:`H_L` is the left limit of the range
over which :math:`g > 0`, and write :math:`g(\eta)` using Equations :eq:`g0` and
:eq:`g1`. In this way we obtain the new areas :math:`a_n` and volumes
:math:`v_n` between the original boundaries :math:`H_{n-1}` and
:math:`H_n` in each category. The new thicknesses,
:math:`h_n = v_n/a_n`, are guaranteed to lie in the range
:math:`(H_{n-1}, H_n)`. If :math:`g = 0` in the part of a category that
is remapped to a neighboring category, no ice is transferred.

Other conserved quantities are transferred in proportion to the ice
volume :math:`\Delta v_{in}`. For example, the transferred ice energy in
layer :math:`k` is
:math:`\Delta e_{ink} = e_{ink} (\Delta v_{in} / v_{in})`.

The left and right boundaries of the domain require special treatment.
If ice is growing in open water at a rate :math:`F_0`, the left boundary
:math:`H_0` is shifted to the right by :math:`F_0 \Delta t` before
:math:`g` is constructed in category 1, then reset to zero after the
remapping is complete. New ice is then added to the grid cell,
conserving area, volume, and energy. If ice cannot grow in open water
(because the ocean is too warm or the net surface energy flux is
downward), :math:`H_0` is fixed at zero, and the growth rate at the left
boundary is estimated as :math:`F_0 = f_1`. If :math:`F_0 < 0`, all ice
thinner than :math:`\Delta h_0 = -F_0 \Delta t` is assumed to have
melted, and the ice area in category 1 is reduced accordingly. The area
of new open water is

.. math:: 
   \Delta a_0 = \int_{0}^{\Delta h_0} g \, dh.
   :label: a0

The right boundary :math:`H_N` is not fixed but varies with
:math:`h_N`, the mean ice thickness in the thickest category. Given
:math:`h_N`, we set :math:`H_N = 3 h_N - 2 H_{N-1}`, which ensures that
:math:`g(h) > 0` for :math:`H_{N-1} < h < H_N` and :math:`g(h) = 0` for
:math:`h \geq H_N`. No ice crosses the right boundary. If the ice growth
or melt rates in a given grid cell are too large, the thickness
remapping scheme will not work. Instead, the thickness categories in
that grid cell are treated as delta functions following
:cite:`BHWE01`, and categories outside their prescribed
boundaries are merged with neighboring categories as needed. For time
steps of less than a day and category thickness ranges of 10 cm or more,
this simplification is needed rarely, if ever.

The linear remapping algorithm for thickness is not monotonic for
tracers, although significant errors rarely occur. Usually they appear
as snow temperatures (enthalpy) outside the physical range of values in
very small snow volumes. In this case we transfer the snow and its heat
and tracer contents to the ocean.


.. _mech-red:

Mechanical redistribution
-------------------------

The last term on the right-hand side of Equation :eq:`transport-g`
is :math:`\psi`, which describes the redistribution
of ice in thickness space due to ridging and other mechanical processes.
The mechanical redistribution scheme in Icepack is based on
:cite:`TRMC75`, :cite:`Rothrock75`,
:cite:`Hibler80`, :cite:`FH95`, and
:cite:`LHMJ07`. This scheme converts thinner ice to thicker
ice and is applied after horizontal transport. When the ice is
converging, enough ice ridges to ensure that the ice area does not
exceed the grid cell area.

First we specify the participation function: the thickness distribution
:math:`a_P(h) = b(h) \, g(h)` of the ice participating in ridging. (We
use "ridging" as shorthand for all forms of mechanical redistribution,
including rafting.) The weighting function :math:`b(h)` favors ridging
of thin ice and closing of open water in preference to ridging of
thicker ice. There are two options for the form of :math:`b(h)`. If
``krdg_partic`` = 0 in the namelist, we follow :cite:`TRMC75`
and set

.. math::
   b(h) = \left\{\begin{array}{ll}  
          \frac{2}{G^*}(1-\frac{G(h)}{G^*}) & \mbox{if $G(h)<G^*$} \\
                    0                       & \mbox{otherwise}   
                 \end{array}  \right.
   :label: partic-old-contin

where :math:`G(h)` is the fractional area covered by ice thinner than
:math:`h`, and :math:`G^*` is an empirical constant. Integrating
:math:`a_P(h)` between category boundaries :math:`H_{n-1}` and
:math:`H_n`, we obtain the mean value of :math:`a_P` in category
:math:`n`:

.. math::
   a_{Pn} = \frac{2}{G^*} (G_n - G_{n-1})
            \left( 1 - \frac{G_{n-1}+G_n}{2 G^*} \right),
   :label: partic-old-discrete

where :math:`a_{Pn}` is the ratio of the ice area ridging (or open
water area closing) in category :math:`n` to the total area ridging and
closing, and :math:`G_n` is the total fractional ice area in categories
0 to :math:`n`. Equation :eq:`partic-old-discrete` applies to
categories with :math:`G_n < G^*`. If :math:`G_{n-1} < G^* < G_n`, then
Equation :eq:`partic-old-discrete` is valid with :math:`G^*` replacing
:math:`G_n`, and if :math:`G_{n-1} > G^*`, then :math:`a_{Pn} = 0`. If
the open water fraction :math:`a_0 > G^*`, no ice can ridge, because
"ridging" simply reduces the area of open water. As in
:cite:`TRMC75` we set :math:`G^* = 0.15`.

If the spatial resolution is too fine for a given time step
:math:`\Delta t`, the weighting function Equation :eq:`partic-old-contin` can
promote numerical instability. For :math:`\Delta t = \mbox{1 hour}`,
resolutions finer than :math:`\Delta x \sim \mbox{10 km}` are typically
unstable. The instability results from feedback between the ridging
scheme and the dynamics via the ice strength. If the strength changes
significantly on time scales less than :math:`\Delta t`, the
viscous-plastic solution of the momentum equation is inaccurate and
sometimes oscillatory. As a result, the fields of ice area, thickness,
velocity, strength, divergence, and shear can become noisy and
unphysical.

A more stable weighting function was suggested by
:cite:`LHMJ07`:

.. math::
   b(h) = \frac{\exp[-G(h)/a^*]}
               {a^*[1-\exp(-1/a^*)]}
   :label: partic-new-contin

When integrated between category boundaries, Equation :eq:`partic-new-contin`
implies

.. math::
   a_{Pn} = \frac {\exp(-G_{n-1}/a^*) - \exp(-G_{n}/a^*)}
                  {1 - \exp(-1/a^*)}
   :label: partic-new-discrete

This weighting function is used if ``krdg_partic`` = 1 in the namelist.
From Equation :eq:`partic-new-contin`, the mean value of :math:`G` for ice
participating in ridging is :math:`a^*`, as compared to :math:`G^*/3`
for Equation :eq:`partic-old-contin`. For typical ice thickness distributions,
setting :math:`a^* = 0.05` with ``krdg_partic`` = 1 gives participation
fractions similar to those given by :math:`G^* = 0.15` with ``krdg_partic``
= 0. See :cite:`LHMJ07` for a detailed comparison of these
two participation functions.

Thin ice is converted to thick, ridged ice in a way that reduces the
total ice area while conserving ice volume and internal energy. There
are two namelist options for redistributing ice among thickness
categories. If ``krdg_redist`` = 0, ridging ice of thickness :math:`h_n`
forms ridges whose area is distributed uniformly between
:math:`H_{\min} = 2 h_n` and :math:`H_{\max} = 2 \sqrt{H^* h_n}`, as in
:cite:`Hibler80`. The default value of :math:`H^*` is 25 m, as
in earlier versions of CICE. Observations suggest that
:math:`H^* = 50` m gives a better fit to first-year ridges
:cite:`AMI04`, although the lower value may be appropriate
for multiyear ridges :cite:`FH95`. The ratio of the mean
ridge thickness to the thickness of ridging ice is
:math:`k_n = (H_{\min} + H_{\max}) / (2 h_n)`. If the area of category
:math:`n` is reduced by ridging at the rate :math:`r_n`, the area of
thicker categories grows simultaneously at the rate :math:`r_n/k_n`.
Thus the *net* rate of area loss due to ridging of ice in category
:math:`n` is :math:`r_n(1-1/k_n)`.

The ridged ice area and volume are apportioned among categories in the
thickness range :math:`(H_{\min}, H_{\max})`. The fraction of the new
ridge area in category :math:`m` is

.. math::
   f_m^{\mathrm{area}} = \frac{H_R - H_L} 
                              {H_{\max} - H_{\min}},
   :label: ridge-area-old

where :math:`H_L = \max(H_{m-1},H_{\min})` and
:math:`H_R= \min(H_m,H_{\max})`. The fraction of the ridge volume going
to category :math:`m` is

.. math::
   f_m^{\mathrm{vol}} = \frac{(H_R)^2 - (H_L)^2}
                             {(H_{\max})^2 - (H_{\min})^2}.
   :label: ridge-volume-old

This uniform redistribution function tends to produce too little ice in
the 3–5 m range and too much ice thicker than 10 m
:cite:`AMI04`. Observations show that the ITD of ridges is
better approximated by a negative exponential. Setting ``krdg_redist`` = 1
gives ridges with an exponential ITD :cite:`LHMJ07`:

.. math::
   g_R(h) \propto \exp[-(h - H_{\min})/\lambda]
   :label: redist-new

for :math:`h \ge H_{\min}`, with :math:`g_R(h) = 0` for
:math:`h < H_{\min}`. Here, :math:`\lambda` is an empirical *e*-folding
scale and :math:`H_{\min}=2h_n` (where :math:`h_n` is the thickness of
ridging ice). We assume that :math:`\lambda = \mu h_n^{1/2}`, where
:math:`\mu` (mu\_rdg) is a tunable parameter with units . Thus the mean
ridge thickness increases in proportion to :math:`h_n^{1/2}`, as in
:cite:`Hibler80`. The value :math:`\mu = 4.0`  gives
:math:`\lambda` in the range 1–4 m for most ridged ice. Ice strengths
with :math:`\mu = 4.0`  and ``krdg_redist`` = 1 are roughly comparable to
the strengths with :math:`H^* = 50` m and ``krdg_redist`` = 0.

From Equation :eq:`redist-new` it can be shown that the fractional area going
to category :math:`m` as a result of ridging is

.. math::
   f_m^{\mathrm{area}} = \exp[-(H_{m-1} - H_{\min}) / \lambda] 
                        - \exp[-(H_m - H_{\min}) / \lambda].
   :label: ridge-area-new

The fractional volume going to category :math:`m` is

.. math::
   f_m^{\mathrm{vol}} = \frac{(H_{m-1}+\lambda) \exp[-(H_{m-1}-H_{\min})/\lambda]
                              - (H_m + \lambda) \exp[-(H_m - H_{\min}) / \lambda]}
                                {H_{min} + \lambda}.
   :label: ridge-volume-new

Equations :eq:`ridge-area-new` and :eq:`ridge-volume-new` replace
Equations :eq:`ridge-area-old` and :eq:`ridge-volume-old` when ``krdg_redist``
= 1.

Internal ice energy is transferred between categories in proportion to
ice volume. Snow volume and internal energy are transferred in the same
way, except that a fraction of the snow may be deposited in the ocean
instead of added to the new ridge.

The net area removed by ridging and closing is a function of the strain
rates. Let :math:`R_{\mathrm{net}}` be the net rate of area loss for the
ice pack (i.e., the rate of open water area closing, plus the net rate
of ice area loss due to ridging). Following :cite:`FH95`,
:math:`R_{\mathrm{net}}` is given by

.. math::
   R_{\mathrm{net}} = \frac{C_s}{2}
                    (\Delta - |D_D|) - \min(D_D,0),
   :label: Rnet

where :math:`C_s` is the fraction of shear dissipation energy that
contributes to ridge-building, :math:`D_D` is the divergence, and
:math:`\Delta` is a function of the divergence and shear. These strain
rates are computed by the dynamics scheme. The default value of
:math:`C_s` is 0.25.

Next, define :math:`R_{\mathrm{tot}} = \sum_{n=0}^N r_n`. This rate is
related to :math:`R_{\mathrm{net}}` by

.. math::
   R_{\mathrm{net}} =
      \left[ a_{P0} + \sum_{n=1}^N a_{Pn}\left(1-{1\over k_n}\right)\right]
       R_{\mathrm{tot}}.
   :label: Rtot-Rnet

Given :math:`R_{\mathrm{net}}` from Equation :eq:`Rnet`, we
use Equation :eq:`Rtot-Rnet` to compute :math:`R_{\mathrm{tot}}`. Then the area
ridged in category :math:`n` is given by :math:`a_{rn} = r_n \Delta t`,
where :math:`r_n = a_{Pn} R_{\mathrm{tot}}`. The area of new ridges is
:math:`a_{rn} / k_n`, and the volume of new ridges is :math:`a_{rn} h_n`
(since volume is conserved during ridging). We remove the ridging ice
from category :math:`n` and use Equations :eq:`ridge-area-old`
and :eq:`ridge-volume-old`: (or :eq:`ridge-area-new` and
:eq:`ridge-volume-new`) to redistribute the ice among thicker
categories.

Occasionally the ridging rate in thickness category :math:`n` may be
large enough to ridge the entire area :math:`a_n` during a time interval
less than :math:`\Delta t`. In this case :math:`R_{\mathrm{tot}}` is
reduced to the value that exactly ridges an area :math:`a_n` during
:math:`\Delta t`. After each ridging iteration, the total fractional ice
area :math:`a_i` is computed. If :math:`a_i > 1`, the ridging is
repeated with a value of :math:`R_{\mathrm{net}}` sufficient to yield
:math:`a_i = 1`.

Two tracers for tracking the ridged ice area and volume are available.
The actual tracers are for level (undeformed) ice area (`alvl`) and volume
(`vlvl`), which are easier to implement for a couple of reasons: (1) ice
ridged in a given thickness category is spread out among the rest of the
categories, making it more difficult (and expensive) to track than the
level ice remaining behind in the original category; (2) previously
ridged ice may ridge again, so that simply adding a volume of freshly
ridged ice to the volume of previously ridged ice in a grid cell may be
inappropriate. Although the code currently only tracks level ice
internally, both level ice and ridged ice are available for output.
They are simply related:

.. math::
   \begin{aligned}
   a_{lvl} + a_{rdg} &=& a_i, \\
   v_{lvl} + v_{rdg} &=& v_i.\end{aligned}
   :label: alvl

Level ice area fraction and volume increase with new ice formation and
decrease steadily via ridging processes. Without the formation of new
ice, level ice asymptotes to zero because we assume that both level ice
and ridged ice ridge, in proportion to their fractional areas in a grid
cell (in the spirit of the ridging calculation itself which does not
prefer level ice over previously ridged ice).

The ice strength :math:`P` may be computed in either of two ways. If the
namelist parameter kstrength = 0, we use the strength formula from
:cite:`Hibler79`:

.. math::
   P = P^* h \exp[-C(1-a_i)],
   :label: hib-strength

where :math:`P^* = 27,500 \, \mathrm {N/m}` and :math:`C = 20` are
empirical constants, and :math:`h` is the mean ice thickness.
Alternatively, setting kstrength = 1 gives an ice strength closely
related to the ridging scheme. Following
:cite:`Rothrock75`, the strength is assumed proportional
to the change in ice potential energy :math:`\Delta E_P` per unit area
of compressive deformation. Given uniform ridge ITDs (``krdg_redist`` = 0),
we have

.. math::
   P = C_f \, C_p \, \beta \sum_{n=1}^{N_C}
     \left[ -a_{Pn} \, h_n^2  + \frac{a_{Pn}}{k_n}
        \left( \frac{(H_n^{\max})^3 - (H_n^{\min})^3}
                    {3(H_n^{\max}-H_n^{\min})} \right) \right],
   :label: roth-strength0

where :math:`C_P = (g/2)(\rho_i/\rho_w)(\rho_w-\rho_i)`,
:math:`\beta =R_{\mathrm{tot}}/R_{\mathrm{net}} > 1`
from Equation :eq:`Rtot-Rnet`, and :math:`C_f` is an empirical parameter that
accounts for frictional energy dissipation. Following
:cite:`FH95`, we set :math:`C_f = 17`. The first term in
the summation is the potential energy of ridging ice, and the second,
larger term is the potential energy of the resulting ridges. The factor
of :math:`\beta` is included because :math:`a_{Pn}` is normalized with
respect to the total area of ice ridging, not the net area removed.
Recall that more than one unit area of ice must be ridged to reduce the
net ice area by one unit. For exponential ridge ITDs (``krdg_redist`` = 1),
the ridge potential energy is modified:

.. math::
   P = C_f \, C_p \, \beta \sum_{n=1}^{N_C}
     \left[ -a_{Pn} \, h_n^2  + \frac{a_{Pn}}{k_n}
        \left( H_{\min}^2 + 2H_{\min}\lambda + 2 \lambda^2 \right) \right]
   :label: roth-strength1

The energy-based ice strength given by Equations :eq:`roth-strength0` or
:eq:`roth-strength1` is more physically realistic than the strength
given by Equation :eq:`hib-strength`. However, use of Equation :eq:`hib-strength` is
less likely to allow numerical instability at a given resolution and
time step. See :cite:`LHMJ07` for more details.


.. _thermo:

Thermodynamics
--------------

The current Icepack version includes three thermodynamics
options, the "zero-layer" thermodynamics of :cite:`Semtner76`
(``ktherm`` = 0), the Bitz and Lipscomb model :cite:`BL99`
(``ktherm`` = 1) that assumes a fixed salinity profile, and a new "mushy"
formulation (``ktherm`` = 2) in which salinity evolves
:cite:`THB13`. For each thickness category, Icepack computes
changes in the ice and snow thickness and vertical temperature profile
resulting from radiative, turbulent, and conductive heat fluxes. The ice
has a temperature-dependent specific heam to simulate the effect of
brine pocket melting and freezing, for ``ktherm`` = 1 and 2.

Each thickness category :math:`n` in each grid cell is treated as a
horizontally uniform column with ice thickness
:math:`h_{in} = v_{in}/a_{in}` and snow thickness
:math:`h_{sn} = v_{sn}/a_{in}`. (Henceforth we omit the category
index \ :math:`n`.) Each column is divided into :math:`N_i` ice layers
of thickness :math:`\Delta h_i = h_i/N_i` and :math:`N_s` snow layers of
thickness :math:`\Delta h_s = h_s/N_s`. The surface temperature (i.e.,
the temperature of ice or snow at the interface with the atmosphere) is
:math:`T_{sf}`, which cannot exceed . The temperature at the
midpoint of the snow layer is :math:`T_s`, and the midpoint ice layer
temperatures are :math:`T_{ik}`, where :math:`k` ranges from 1 to
:math:`N_i`. The temperature at the bottom of the ice is held at
:math:`T_f`, the freezing temperature of the ocean mixed layer. All
temperatures are in degrees Celsius unless stated otherwise.

Each ice layer has an enthalpy :math:`q_{ik}`, defined as the negative
of the energy required to melt a unit volume of ice and raise its
temperature to . Because of internal melting and freezing in brine
pockets, the ice enthalpy depends on the brine pocket volume and is a
function of temperature and salinity. We can also define a snow enthalpy
:math:`q_s`, which depends on temperature alone.

Given surface forcing at the atmosphere–ice and ice–ocean interfaces
along with the ice and snow thicknesses and temperatures/enthalpies at
time :math:`m`, the thermodynamic model advances these quantities to
time :math:`m+1` (``ktherm`` = 2 also advances salinity). The calculation
proceeds in two steps. First we solve a set of equations for the new
temperatures, as discussed in the :ref:`thermo-temp` section. Then we
compute the melting, if any, of ice or snow at the top surface, and the
growth or melting of ice at the bottom surface, as described in
the :ref:`thermo-growth` section. We begin by describing the surface
forcing parameterizations, which are closely related to the ice and snow
surface temperatures.

.. _ponds:

Melt ponds
~~~~~~~~~~

Three explicit melt pond parameterizations are available in Icepack, and
all must use the delta-Eddington radiation scheme, described below. The
default (ccsm3) shortwave parameterization incorporates melt ponds
implicitly by adjusting the albedo based on surface conditions.

For each of the three explicit parameterizations, a volume
:math:`\Delta V_{melt}` of melt water produced on a given category may
be added to the melt pond liquid volume:

.. math:: 
   \Delta V_{melt} = {r\over\rho_w} \left({\rho_{i}}\Delta h_{i} + {\rho_{s}}\Delta h_{s} + F_{rain}{\Delta t}\right) a_i,
   :label: meltvol

where

.. math:: 
   r = r_{min} + \left(r_{max} - r_{min}\right) a_i
   :label: melt-retention

is the fraction of the total melt water available that is added to the
ponds, :math:`\rho_i` and :math:`\rho_s` are ice and snow densities,
:math:`\Delta h_i` and :math:`\Delta h_s` are the thicknesses of ice and
snow that melted, and :math:`F_{rain}` is the rainfall rate. Namelist
parameters are set for the level-ice (``tr_pond_lvl``) parameterization;
in the cesm and topo pond schemes the standard values of :math:`r_{max}`
and :math:`r_{min}` are 0.7 and 0.15, respectively.

Radiatively, the surface of an ice category is divided into fractions of
snow, pond and bare ice. In these melt pond schemes, the actual pond
area and depth are maintained throughout the simulation according to the
physical processes acting on it. However, snow on the sea ice and pond
ice may shield the pond and ice below from solar radiation. These
processes do not alter the actual pond volume; instead they are used to
define an "effective pond fraction" (and likewise, effective pond depth,
snow fraction and snow depth) used only for the shortwave radiation
calculation.

In addition to the physical processes discussed below, tracer equations
and definitions for melt ponds are also described in
the :ref:`tracers` and :ref:`fig-tracers` sections.

**CESM formulation** (``tr_pond_cesm`` = true)

Melt pond area and thickness tracers are carried on each ice thickness
category as in the :ref:`tracers` section. Defined simply as the product
of pond area, :math:`a_p`, and depth, :math:`h_p`, the melt pond volume,
:math:`V_{p}`, grows through addition of ice or snow melt water or rain
water, and shrinks when the ice surface temperature becomes cold,

.. math::
   \begin{aligned}
   {\rm pond \ growth:\ } \ V_{p}^\prime &= V_{p}(t) +\Delta V_{melt} , \\
   {\rm pond \ contraction:\ } \ V_{p}(t+\Delta t) &= V_{p}^\prime\exp\left[r_2\left( {\max\left(T_p-T_{sfc}, 0\right) \over T_p}\right)\right], \end{aligned}
   :label: meltpond-cesm

where :math:`dh_{i}` and :math:`dh_{s}` represent ice and snow melt at
the top surface of each thickness category and :math:`r_2=0.01`. Here,
:math:`T_p` is a reference temperature equal to -2 :math:`^\circ`\ C.
Pond depth is assumed to be a linear function of the pond fraction
(:math:`h_p=\delta_p a_p`) and is limited by the category ice thickness
(:math:`h_p \le 0.9 h_i`). The pond shape (``pndaspect``)
:math:`\delta_p = 0.8` in the standard CESM pond configuration. The area
and thickness are computed according to the assumed pond shape, and the
pond area is then reduced in the presence of snow for the radiation
calculation. Ponds are allowed only on ice at least 1 cm thick. This
formulation differs slightly from that documented in
:cite:`HBBLH12`.

**Topographic formulation** (``tr_pond_topo`` = true)

The principle concept of this scheme is that melt water runs downhill
under the influence of gravity and collects on sea ice with increasing
surface height starting at the lowest height
:cite:`FF07,FFT10,FSFH12`. Thus, the topography of the
ice cover plays a crucial role in determining the melt pond cover.
However, Icepack does not explicitly represent the topography of sea ice.
Therefore, we split the existing ice thickness distribution function
into a surface height and basal depth distribution assuming that each
sea ice thickness category is in hydrostatic equilibrium at the
beginning of the melt season. We then calculate the position of sea
level assuming that the ice in the whole grid cell is rigid and in
hydrostatic equilibrium. 

.. _fig-topo:

.. figure:: ./figures/topo.png
   :align: center
   :scale: 75%

   Figure 6

:ref:`fig-topo` : (a) Schematic illustration of the relationship between the
height of the pond surface :math:`h_{pnd,tot}`, the volume of water
:math:`V_{Pk}` required to completely fill up to category :math:`k`, the
volume of water :math:`V_{P} - V_{Pk}`, and the depth to which this
fills up category :math:`k + 1`. Ice and snow areas :math:`a_i` and
:math:`a_s` are also depicted. The volume calculation takes account of
the presence of snow, which may be partially or completely saturated.
(b) Schematic illustration indicating pond surface height
:math:`h_{pnd,tot}` and sea level :math:`h_{sl}` measured with respect
to the thinnest surface height category :math:`h_{i1}`, the submerged
portion of the floe :math:`h_{sub}`, and hydraulic head :math:`\Delta H`
. A positive hydraulic head (pond surface above sea level) will flush
melt water through the sea ice into the ocean; a negative hydraulic head
can drive percolation of sea water up onto the ice surface. Here,
:math:`\alpha=0.6` and :math:`\beta=0.4` are the surface height and
basal depth distribution fractions. The height of the steps is the
height of the ice above the reference level, and the width of the steps
is the area of ice of that height. The illustration does not imply a
particular assumed topography, rather it is assumed that all thickness
categories are present at the sub-grid scale so that water will always
flow to the lowest surface height class.

Once a volume of water is produced from ice and snow melting, we
calculate the number of ice categories covered by water. At each time
step, we construct a list of volumes of water
:math:`\{V_{P1}, V_{P2}, . . . V_{P,k-1}, V_{Pk},`
:math:`V_{P,k+1}, . . . \}`, where :math:`V_{Pk}` is the volume of water
required to completely cover the ice and snow in the surface height
categories from :math:`i = 1` up to :math:`i = k`. The volume
:math:`V_{Pk}` is defined so that if the volume of water :math:`V_{P}`
is such that :math:`V_{Pk} < V_{P} < V_{P,k+1}` then the snow and ice in
categories :math:`n = 1` up to :math:`n = k + 1` are covered in melt
water. :ref:`fig-topo` (a) depicts the areas covered in melt water and
saturated snow on the surface height (rather than thickness) categories
:math:`h_{top,k}`. Note in the code, we assume that
:math:`h_{top,n}/h_{in} = 0.6` (an arbitrary choice). The fractional
area of the :math:`n`\ th category covered in snow is :math:`a_{sn}`.
The volume :math:`V_{P1}`, which is the region with vertical hatching,
is the volume of water required to completely fill up the first
thickness category, so that any extra melt water must occupy the second
thickness category, and it is given by the expression

.. math::
   V_{P1} = a_{i1} (h_{top,2}-h_{top,1}) - a_{s1} a_{i1} h_{s1} (1-V_{sw}),
   :label: topo-vol1

where :math:`V_{sw}` is the fraction of the snow volume that can be
occupied by water, and :math:`h_{s1}` is the snow depth on ice height
class 1. In a similar way, the volume required to fill up the first and
second surface categories, :math:`V_{P2}`, is given by

.. math::
   V_{P2} = a_{i1} (h_{top,3}-h_{top,2}) + a_{i2} (h_{top,3}-h_{top,2}) - a_{s2} a_{i2} h_{s2} (1-V_{sw}) + V_{P1}.
   :label: topo-vol2

The general expression for volume :math:`V_{Pk}` is given by

.. math::
   V_{Pk} = \sum^k_{m=0} a_{im} (h_{top,k+1}-h_{top,k}) - a_{sk} a_{ik} h_{sk} (1-V_{sw})
             + \sum^{k-1}_{m=0} V_{Pm}.
   :label: topo-vol

(Note that we have implicitly assumed that
:math:`h_{si} < h_{top,k+1} - h_{top,k}` for all :math:`k`.) No melt
water can be stored on the thickest ice thickness category. If the melt
water volume exceeds the volume calculated above, the remaining melt
water is released to the ocean.

At each time step, the pond height above the level of the thinnest
surface height class, that is, the maximum pond depth, is diagnosed from
the list of volumes :math:`V_{Pk}`. In particular, if the total volume
of melt water :math:`V_{P}` is such that
:math:`V_{Pk} < V_{P} < V_{P,k+1}` then the pond height
:math:`h_{pnd,tot}` is

.. math::
   h_{pnd,tot} = h_{par} + h_{top,k} - h_{top,1},
   :label: topo_hpnd_tot

where :math:`h_{par}` is the height of the pond above the level of the
ice in class :math:`k` and partially fills the volume between
:math:`V_{P,k}` and :math:`V_{P,k+1}`. From :ref:`fig-topo` (a) we see
that :math:`h_{top,k} - h_{top,1}` is the height of the melt water,
which has volume :math:`V_{Pk}`, which completely fills the surface
categories up to category :math:`k`. The remaining volume,
:math:`V_{P} - V_{Pk}`, partially fills category :math:`k + 1` up to the
height :math:`h_{par}` and there are two cases to consider: either the
snow cover on category :math:`k + 1`, with height :math:`h_{s,k+1}`, is
completely covered in melt water (i.e., :math:`h_{par} > h_{s,k+1}`), or
it is not (i.e., :math:`h_{par} \le h_{s,k+1}`). From conservation of
volume, we see from :ref:`fig-topo` (a) that for an incompletely to
completely saturated snow cover on surface ice class :math:`k + 1`,

.. math::
   \begin{aligned}
   V_{P} - V_{Pk} & = & h_{par} \left( \sum^k_{m=1} a_{ik} + a_{i,k+1}(1-a_{s,k+1}) 
   + a_{i,k+1} a_{s,k+1} V_{sw} \right) 
   & & {\rm for} \hspace{3mm} h_{par} \le h_{s,k+1},\end{aligned}
   :label: topo-satsnow1

and for a saturated snow cover with water on top of the snow on surface
ice class :math:`k + 1`,

.. math::
   \begin{aligned}
   V_{P} - V_{Pk} & = & h_{par} \left( \sum^k_{m=1} a_{ik} + a_{i,k+1}(1-a_{s,k+1}) \right) 
      + a_{i,k+1} a_{s,k+1} V_{sw} h_{s,k+1} \\ 
   & + & a_{i,k+1} a_{s,k+1} (h_{par}-h_{s,k+1})
   & & {\rm for} \hspace{3mm} h_{par} > h_{s,k+1}.\end{aligned}
   :label: topo-satsnow2

As the melting season progresses, not only does melt water accumulate
upon the upper surface of the sea ice, but the sea ice beneath the melt
water becomes more porous owing to a reduction in solid fraction
:cite:`EGPRF04`. The hydraulic head of melt water on sea
ice (i.e., its height above sea level) drives flushing of melt water
through the porous sea ice and into the underlying ocean. The mushy
thermodynamics scheme (`ktherm` = 2) handles flushing. For
`ktherm` :math:`\ne 2` we model the vertical flushing rate using Darcy’s
law for flow through a porous medium

.. math::
   w = - \frac{\Pi_v}{\mu} \rho_o g \frac{\Delta H}{h_i},
   :label: topo-darcy

where :math:`w` is the vertical mass flux per unit perpendicular
cross-sectional area (i.e., the vertical component of the Darcy
velocity), :math:`\Pi_v` is the vertical component of the permeability
tensor (assumed to be isotropic in the horizontal), :math:`\mu` is the
viscosity of water, :math:`\rho_o` is the ocean density, :math:`g` is
gravitational acceleration, :math:`\Delta H` is the the hydraulic head,
and :math:`h_i` is the thickness of the ice through which the pond
flushes. As proposed by :cite:`GEHMPZ07` the vertical
permeability of sea ice can be calculated from the liquid fraction
:math:`\phi`:

.. math::
   \Pi_v = 3 \times 10^{-8} \phi^3 \rm{m^2}.
   :label: topo-permea

Since the solid fraction varies throughout the depth of the sea ice, so
does the permeability. The rate of vertical drainage is determined by
the lowest (least permeable) layer, corresponding to the highest solid
fraction. From the equations describing sea ice as a mushy layer
:cite:`FUWW06`, the solid fraction is determined by:

.. math::
   \phi = \frac{c_i-S}{c_i-S_{br}(T)},
   :label: topo-solid

where :math:`S` is the bulk salinity of the ice, :math:`S_{br}(T)` is
the concentration of salt in the brine at temperature :math:`T` and
:math:`c_i` is the concentration of salt in the ice crystals (set to
zero).

The hydraulic head is given by the difference in height between the
upper surface of the melt pond :math:`h_{pnd,tot}` and the sea level
:math:`h_{sl}`. The value of the sea level :math:`h_{sl}` is calculated
from

.. math::
   h_{sl} = h_{sub} - 0.4 \sum^{N}_{n=1} a_{in} h_{in} - \beta h_{i1},
   :label: topo-hsl1

where :math:`0.4 \sum^{N}_{n=1} a_{in} h_{i,n}` is the mean thickness
of the basal depth classes, and :math:`h_{sub}` is the depth of the
submerged portion of the floe. :ref:`fig-topo` (b) depicts the
relationship between the hydraulic head and the depths and heights that
appear in Equation :eq:`topo-hsl1`. The depth of the submerged portion
of the floe is determined from hydrostatic equilibrium to be

.. math::
   h_{sub} = \frac{\rho_m}{\rho_w} V_P + \frac{\rho_s}{\rho_w} V_s + \frac{\rho_i}{\rho_w} V_i,
   :label: topo-hsl2

where :math:`\rho_m` is the density of melt water, :math:`V_P` is the
total pond volume, :math:`V_s` is the total snow volume, and :math:`V_i`
is the total ice volume.

When the surface energy balance is negative, a layer of ice is formed at
the upper surface of the ponds. The rate of growth of the ice lid is
given by the Stefan energy budget at the lid-pond interface

.. math::
   \rho_i L_0 \frac{d h_{ipnd}}{dt} = k_i \frac{\partial T_i}{\partial z} - k_p \frac{\partial T_p}{\partial z},
   :label: topo-lid

where :math:`L_0` is the latent heat of fusion of pure ice per unit
volume, :math:`T_i` and :math:`T_p` are the ice surface and pond
temperatures, and :math:`k_i` and :math:`k_p` are the thermal
conductivity of the ice lid and pond respectively. The second term on
the right hand-side is close to zero since the pond is almost uniformly
at the freezing temperature :cite:`TF04`. Approximating the
temperature gradient in the ice lid as linear, the Stefan condition
yields the classic Stefan solution for ice lid depth

.. math::
   h_{ipnd} = \sqrt{\frac{2k_i}{\rho_s L}\Delta T_i t},
   :label: topo-stefan

where :math:`\Delta T` is the temperature difference between the top
and the bottom of the lid. Depending on the surface flux conditions the
ice lid can grow, partially melt, or melt completely. Provided that the
ice lid is thinner than a critical lid depth (1 cm is suggested) then
the pond is regarded as effective, i.e. the pond affects the optical
properties of the ice cover. Effective pond area and pond depth for each
thickness category are passed to the radiation scheme for calculating
albedo. Note that once the ice lid has exceeded the critical thickness,
snow may accumulate on the lid causing a substantial increase in albedo.
In the current CICE model, melt ponds only affect the thermodynamics of
the ice through the albedo. To conserve energy, the ice lid is dismissed
once the pond is completely refrozen.

As the sea ice area shrinks due to melting and ridging, the pond volume
over the lost area is released to the ocean immediately. In
:cite:`FFT10`, the pond volume was carried as an ice area
tracer, but in :cite:`FSFH12` and here, pond area and
thickness are carried as separate tracers, as in
the :ref:`tracers` section.

Unlike the cesm and level-ice melt pond schemes, the liquid pond water
in the topo parameterization is not necessarily virtual; it can be
withheld from being passed to the ocean model until the ponds drain by
setting the namelist variable ``l_mpond_fresh`` = .true. The refrozen pond
lids are still virtual. Extra code needed to track and enforce
conservation of water has been added to **icepack\_itd.F90** (subroutine
*zap\_small\_areas*), **icepack\_mechred.F90** (subroutine *ridge\_shift*),
**icepack\_therm\_itd.F90** (subroutines *linear\_itd* and *lateral\_melt*),
and **icepack\_therm\_vertical.F90** (subroutine *thermo\_vertical*), along
with global diagnostics in **icepack\_diagnostics.F90**.

**Level-ice formulation** (``tr_pond_lvl`` = true)

This meltpond parameterization represents a combination of ideas from
the empirical CESM melt pond scheme and the topo approach, and is
documented in :cite:`HHL13`. The ponds evolve according to
physically based process descriptions, assuming a thickness-area ratio
for changes in pond volume. A novel aspect of the new scheme is that the
ponds are carried as tracers on the level (undeformed) ice area of each
thickness category, thus limiting their spatial extent based on the
simulated sea ice topography. This limiting is meant to approximate the
horizontal drainage of melt water into depressions in ice floes. (The
primary difference between the level-ice and topo meltpond
parameterizations lies in how sea ice topography is taken into account
when determining the areal coverage of ponds.) Infiltration of the snow
by melt water postpones the appearance of ponds and the subsequent
acceleration of melting through albedo feedback, while snow on top of
refrozen pond ice also reduces the ponds’ effect on the radiation
budget.

Melt pond processes, described in more detail below, include addition of
liquid water from rain, melting snow and melting surface ice, drainage
of pond water when its weight pushes the ice surface below sea level or
when the ice interior becomes permeable, and refreezing of the pond
water. If snow falls after a layer of ice has formed on the ponds, the
snow may block sunlight from reaching the ponds below. When melt water
forms with snow still on the ice, the water is assumed to infiltrate the
snow. If there is enough water to fill the air spaces within the
snowpack, then the pond becomes visible above the snow, thus decreasing
the albedo and ultimately causing the snow to melt faster. The albedo
also decreases as snow depth decreases, and thus a thin layer of snow
remaining above a pond-saturated layer of snow will have a lower albedo
than if the melt water were not present.

The level-ice formulation assumes a thickness-area ratio for *changes*
in pond volume, while the CESM scheme assumes this ratio for the total
pond volume. Pond volume changes are distributed as changes to the area
and to the depth of the ponds using an assumed aspect ratio, or shape,
given by the parameter :math:`\delta_p` (``pndaspect``),
:math:`\delta_p = {\Delta h_p / \Delta a_{p}}` and
:math:`\Delta V = \Delta h_p \Delta a_{p} = \delta_p\Delta a_p^2  = \Delta h_{p}^2/\delta_p`.
Here, :math:`a_{p} = a_{pnd} a_{lvl}`, the mean pond area over the ice.

Given the ice velocity :math:`\bf u`, conservation equations for level
ice fraction :math:`a_{lvl}a_i`, pond area fraction
:math:`a_{pnd}a_{lvl}a_i`, pond volume :math:`h_{pnd}a_{pnd}a_{lvl}a_i`
and pond ice volume :math:`h_{ipnd}a_{pnd}a_{lvl}a_i` are

.. math::
   {\partial\over\partial t} (a_{lvl}a_{i}) + \nabla \cdot (a_{lvl}a_{i} {\bf u}) = 0,
   :label: transport-lvl

.. math::
   {\partial\over\partial t} (a_{pnd}a_{lvl}a_{i}) + \nabla \cdot (a_{pnd}a_{lvl}a_{i} {\bf u}) = 0,
   :label: transport-apnd-lvl   

.. math::
   {\partial\over\partial t} (h_{pnd}a_{pnd}a_{lvl}a_{i}) + \nabla \cdot (h_{pnd}a_{pnd}a_{lvl}a_{i} {\bf u}) = 0,
   :label: transport-hpnd-lvl

.. math::
   {\partial\over\partial t} (h_{ipnd}a_{pnd}a_{lvl}a_{i}) + \nabla \cdot (h_{ipnd}a_{pnd}a_{lvl}a_{i} {\bf u}) = 0.
   :label: transport-ipnd-lvl

(We have dropped the category subscript here, for clarity.) Equations
:eq:`transport-hpnd-lvl` and :eq:`transport-ipnd-lvl` express
conservation of melt pond volume and pond ice volume, but in this form
highlight that the quantities tracked in the code are the tracers
:math:`h_{pnd}` and :math:`h_{ipnd}`, pond depth and pond ice thickness.
Likewise, the level ice fraction :math:`a_{lvl}` is a tracer on ice area
fraction (Equation :eq:`transport-lvl`), and pond fraction :math:`a_{pnd}` is
a tracer on level ice (Equation :eq:`transport-apnd-lvl`).

*Pond ice.* The ponds are assumed to be well mixed fresh water, and
therefore their temperature is 0\ :math:`^\circ`\ C. If the air
temperature is cold enough, a layer of clear ice may form on top of the
ponds. There are currently three options in the code for refreezing the
pond ice. Only option A tracks the thickness of the lid ice using the
tracer :math:`h_{ipnd}` and includes the radiative effect of snow on top
of the lid.

A. The ``frzpnd`` = ‘hlid’ option uses a Stefan approximation for growth of
fresh ice and is invoked only when :math:`\Delta V_{melt}=0`.

The basic thermodynamic equation governing ice growth is

.. math::
   \rho_i L {\partial h_i\over\partial t} = k_i{\partial T_i\over\partial z} \sim k_i {\Delta T\over h_i}
   :label: Stefanthermo1

assuming a linear temperature profile through the ice thickness
:math:`h_i`. In discrete form, the solution is

.. math::
   \Delta h_i = \left\{ 
   \begin{array}{ll}    {\sqrt{\beta\Delta t}/2} & \mbox {if $h_i=0$} \\
                                   {\beta\Delta t / 2 h_i} & \mbox {if $h_i>0,$} 
   \end{array} \right.
   :label: hi

where

.. math:: 
   \beta = {2 k_i \Delta T \over \rho_i L} .
   :label: beta

When :math:`\Delta V_{melt}>0`, any existing pond ice may also melt. In
this case,

.. math::
   \Delta h_i = -\min\left({\max(F_\circ, 0) \Delta t \over \rho_i L}, h_i\right),
   :label: ipndmelt

where :math:`F_\circ` is the net downward surface flux.

In either case, the change in pond volume associated with growth or melt
of pond ice is

.. math::
   \Delta V_{frz} = -\Delta h_i a_{pnd} a_{lvl} a_i {\rho_i/\rho_0},
   :label: vfrz

where :math:`\rho_0` is the density of fresh water.

B. The ``frzpnd`` = ‘cesm’ option uses the same empirical function as in the
CESM melt pond parameterization.

*Radiative effects.* Freshwater ice that has formed on top of a melt
pond is assumed to be perfectly clear. Snow may accumulate on top of the
pond ice, however, shading the pond and ice below. The depth of the snow
on the pond ice is initialized as :math:`h_{ps}^0 = F_{snow}\Delta t` at
the first snowfall after the pond ice forms. From that time until either
the pond ice or the pond snow disappears, the pond snow depth tracks the
depth of snow on sea ice (:math:`h_s`) using a constant difference
:math:`\Delta`. As :math:`h_s` melts, :math:`h_{ps}=h_s-\Delta` will be
reduced to zero eventually, at which time the pond ice is fully
uncovered and shortwave radiation passes through.

To prevent a sudden change in the shortwave reaching the sea ice (which
can prevent the thermodynamics from converging), thin layers of snow on
pond ice are assumed to be patchy, thus allowing the shortwave flux to
increase gradually as the layer thins. This is done using the same
parameterization for patchy snow as is used elsewhere in Icepack, but with
its own parameter :math:`h_{s1}`:

.. math:: 
   a_{pnd}^{eff} = \left(1 - \min\left(h_{ps}/h_{s1}, 1\right)\right) a_{pnd} a_{lvl}.
   :label: apndeff

If any of the pond ice melts, the radiative flux allowed to pass through
the ice is reduced by the (roughly) equivalent flux required to melt
that ice. This is accomplished (approximately) with
:math:`a_{pnd}^{eff} = (1-f_{frac})a_{pnd}a_{lvl}`, where (see
Equation :eq:`ipndmelt`)

.. math:: 
   f_{frac} = \min\left(-{\rho_i L\Delta h_i\over F_\circ \Delta t}, 1 \right) .
   :label: snowinf

*Snow infiltration by pond water.* If there is snow on top of the sea
ice, melt water may infiltrate the snow. It is a "virtual process" that
affects the model’s thermodynamics through the input parameters of the
radiation scheme; it does not melt the snow or affect the snow heat
content.

A snow pack is considered saturated when its percentage of liquid water
content is greater or equal to 15% (Sturm and others, 2009). We assume
that if the volume fraction of retained melt water to total liquid
content

.. math:: 
   r_p = {V_p\over V_p + V_s \rho_s / \rho_0} < 0.15,
   :label: snowinf2

then effectively there are no meltponds present, that is,
:math:`a_{pnd}^{eff}=h_{pnd}^{eff}=0`. Otherwise, we
assume that the snowpack is saturated with liquid water.

We assume that all of the liquid water accumulates at the base of the
snow pack and would eventually melt the surrounding snow. Two
configurations are therefore possible, (1) the top of the liquid lies
below the snow surface and (2) the liquid water volume overtops the
snow, and all of the snow is assumed to have melted into the pond. The
volume of void space within the snow that can be filled with liquid melt
water is

.. math:: 
   V_{mx}=h_{mx}a_{p} = {\left(\rho_0-\rho_s\over \rho_0\right)}h_s a_{p},
   :label: volmelt

and we compare :math:`V_p` with :math:`V_{mx}`.

Case 1: For :math:`V_p < V_{mx}`, we define :math:`V_p^{eff}` to
be the volume of void space filled by the volume :math:`V_p` of melt
water: :math:`\rho_0 V_p =  (\rho_0-\rho_s) V_p^{eff},` or in
terms of depths,

.. math:: 
   h_p^{eff} = {\left(\rho_0  \over \rho_0 - \rho_s\right)}h_{pnd}.
   :label: hpndeff

The liquid water under the snow layer is not visible and therefore the
ponds themselves have no direct impact on the radiation
(:math:`a_{pnd}^{eff}=h_{pnd}^{eff}=0`), but the
effective snow thickness used for the radiation scheme is reduced to

.. math:: 
   h_s^{eff} = h_s - h_p^{eff}a_p = h_s - {\rho_0 \over \rho_0 - \rho_s}h_{pnd} a_p.
   :label: hseff

Here, the factor :math:`a_p=a_{pnd}a_{lvl}` averages the reduced snow
depth over the ponds with the full snow depth over the remainder of the
ice; that is, :math:`h_s^{eff} = h_s(1-a_p) + (h_s -h_p^{eff})a_p.`

Case 2: Similarly, for :math:`V_p \ge V_{mx}`, the total mass in the
liquid is :math:`\rho_0 V_p + \rho_s V_s = \rho_0 V_p^{eff},` or

.. math:: 
   h_p^{eff} = {\rho_0 h_{pnd} + \rho_s h_{s} \over \rho_0}.
   :label: hpeff

Thus the effective depth of the pond is the depth of the whole slush
layer :math:`h_p^{eff}`. In this case,
:math:`a_{pnd}^{eff}=a_{pnd}a_{lvl}`.

*Drainage.* A portion :math:`1-r` of the available melt water drains
immediately into the ocean. Once the volume changes described above have
been applied and the resulting pond area and depth calculated, the pond
depth may be further reduced if the top surface of the ice would be
below sea level or if the sea ice becomes permeable.

We require that the sea ice surface remain at or above sea level. If the
weight of the pond water would push the mean ice–snow interface of a
thickness category below sea level, some or all of the pond water is
removed to bring the interface back to sea level via Archimedes’
Principle written in terms of the draft :math:`d`,

.. math:: 
   \rho_i h_i + \rho_s h_s + \rho_0 h_p = \rho_w d \le \rho_w h_i.
   :label: freeboard

There is a separate freeboard calculation in the thermodynamics which
considers only the ice and snow and converts flooded snow to sea ice.
Because the current melt ponds are "virtual" in the sense that they only
have a radiative influence, we do not allow the pond mass to change the
sea ice and snow masses at this time, although this issue may need to be
reconsidered in the future, especially for the Antarctic.

The mushy thermodynamics scheme (`ktherm` = 2) handles flushing.
For `ktherm` :math:`\ne 2`, the permeability of the sea ice is calculated
using the internal ice temperatures :math:`T_i` (computed from the
enthalpies as in the sea ice thermodynamics). The brine salinity and
liquid fraction are given by :cite:`Notz05` [eq 3.6]
:math:`S_{br} = {1/ (10^{-3} - 0.054/T_i)}` and :math:`\phi = S/S_{br}`,
where :math:`S` is the bulk salinity of the combined ice and brine. The
ice is considered permeable if :math:`\phi \ge 0.05` with a permeability
of :math:`p=3\times 10^{-8}\min(\phi^3)` (the minimum being taken over
all of the ice layers). A hydraulic pressure head is computed as
:math:`P=g\rho_w\Delta h` where :math:`\Delta h` is the height of the
pond and sea ice above sea level. Then the volume of water drained is
given by

.. math:: 
   \Delta V_{perm} = -a_{pnd} \min\left(h_{pnd}, {p P d_p \Delta t \over \mu h_i}\right),
   :label: vperm

where :math:`d_p` is a scaling factor (dpscale), and
:math:`\mu=1.79\times 10^{-3}` kg m :math:`^{-1}` s :math:`^{-1}` is the
dynamic viscosity.

*Conservation elsewhere.* When ice ridges and when new ice forms in open
water, the level ice area changes and ponds must be handled
appropriately. For example, when sea ice deforms, some of the level ice
is transformed into ridged ice. We assume that pond water (and ice) on
the portion of level ice that ridges is lost to the ocean. All of the
tracer volumes are altered at this point in the code, even though
:math:`h_{pnd}` and :math:`h_{ipnd}` should not change; compensating
factors in the tracer volumes cancel out (subroutine *ridge\_shift* in
**icepack\_mechred.F90**).

When new ice forms in open water, level ice is added to the existing sea
ice, but the new level ice does not yet have ponds on top of it.
Therefore the fractional coverage of ponds on level ice decreases
(thicknesses are unchanged). This is accomplished in
**icepack\_therm\_itd.F90** (subroutine *add\_new\_ice*) by maintaining the
same mean pond area in a grid cell after the addition of new ice,

.. math:: 
   a_{pnd}^\prime (a_{lvl}+\Delta a_{lvl}) (a_i+\Delta a_i)   = a_{pnd} a_{lvl} a_i,
   :label: apndprime

and solving for the new pond area tracer :math:`a_{pnd}^\prime` given
the newly formed ice area :math:`\Delta a_i = \Delta a_{lvl}`.

.. _sfc-forcing:

Thermodynamic surface forcing balance
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

The net surface energy flux from the atmosphere to the ice (with all
fluxes defined as positive downward) is

.. math::
   F_0 = F_s + F_l + F_{L\downarrow} + F_{L\uparrow} +
            (1-\alpha) (1-i_0) F_{sw},
   :label: f0

where :math:`F_s` is the sensible heat flux, :math:`F_l` is the latent
heat flux, :math:`F_{L\downarrow}` is the incoming longwave flux,
:math:`F_{L\uparrow}` is the outgoing longwave flux, :math:`F_{sw}` is
the incoming shortwave flux, :math:`\alpha` is the shortwave albedo, and
:math:`i_0` is the fraction of absorbed shortwave flux that penetrates
into the ice. The albedo may be altered by the presence of melt ponds.
Each of the explicit melt pond parameterizations (CESM, topo and
level-ice ponds) should be used in conjunction with the Delta-Eddington
shortwave scheme, described below.

*Shortwave radiation: Delta-Eddington*

Two methods for computing albedo and shortwave fluxes are available, the
"ccsm3" method, described below, and a multiple scattering
radiative transfer scheme that uses a Delta-Eddington approach.
"Inherent" optical properties (IOPs) for snow and sea ice, such as
extinction coefficient and single scattering albedo, are prescribed
based on physical measurements; reflected, absorbed and transmitted
shortwave radiation ("apparent" optical properties) are then computed
for each snow and ice layer in a self-consistent manner. Absorptive
effects of inclusions in the ice/snow matrix such as dust and algae can
also be included, along with radiative treatment of melt ponds and other
changes in physical properties, for example granularization associated
with snow aging. The Delta-Eddington formulation is described in detail
in :cite:`BL07`. Since publication of this technical paper,
a number of improvements have been made to the Delta-Eddington scheme,
including a surface scattering layer and internal shortwave absorption
for snow, generalization for multiple snow layers and more than four
layers of ice, and updated IOP values.

The namelist parameters ``R_ice`` and ``R_pnd`` adjust the albedo of bare or
ponded ice by the product of the namelist value and one standard
deviation. For example, if ``R_ice`` = 0.1, the albedo increases by
:math:`0.1\sigma`. Similarly, setting ``R_snw`` = 0.1 decreases the snow
grain radius by :math:`0.1\sigma` (thus increasing the albedo). Two
additional tuning parameters are available for this scheme, ``dT_mlt`` and
``rsnw_mlt``. ``dT_mlt`` is the temperature change needed for a change in snow
grain radius from non-melting to melting, and ``rsnw_mlt`` is the maximum
snow grain radius when melting. An absorption coefficient for algae
(``kalg``) may also be set. See :cite:`BL07` for details; the
CESM melt pond and Delta-Eddington parameterizations are further
explained and validated in :cite:`HBBLH12`.

*Shortwave radiation: CCSM3*

In the parameterization used in the previous version of the Community
Climate System Model (CCSM3), the albedo depends on the temperature and
thickness of ice and snow and on the spectral distribution of the
incoming solar radiation. Albedo parameters have been chosen to fit
observations from the SHEBA field experiment. For
:math:`T_{sf} < -1^{\circ}C` and :math:`h_i > ` ``ahmax``, the bare ice
albedo is 0.78 for visible wavelengths (:math:`<700`\ nm) and 0.36 for
near IR wavelengths (:math:`>700`\ nm). As :math:`h_i` decreases from
ahmax to zero, the ice albedo decreases smoothly (using an arctangent
function) to the ocean albedo, 0.06. The ice albedo in both spectral
bands decreases by 0.075 as :math:`T_{sf}` rises from
:math:`-1^{\circ}C` to . The albedo of cold snow (:math:`T_{sf} <
-1^{\circ}C`) is 0.98 for visible wavelengths and 0.70 for near IR
wavelengths. The visible snow albedo decreases by 0.10 and the near IR
albedo by 0.15 as :math:`T_{sf}` increases from :math:`-1^{\circ}C`
to :math:`0^{\circ}C`. The total albedo is an area-weighted average of the ice and snow
albedos, where the fractional snow-covered area is

.. math:: 
   f_{snow} = \frac{h_s}{h_s + h_{snowpatch}},
   :label: snowfrac

and :math:`h_{snowpatch} = 0.02 \ {\mathrm m}`. The envelope
of albedo values is shown in :ref:`fig-albedo`. This albedo
formulation incorporates the effects of melt ponds implicitly; the
explicit melt pond parameterization is not used in this case.

.. _fig-albedo:

.. figure:: ./figures/albedo.png
   :align: center
   :scale: 20%
 
   Figure 7

:ref:`fig-albedo` : Albedo as a function of ice thickness and temperature,
for the two extrema in snow depth, for the default (CCSM3) shortwave
option. Maximum snow depth is computed based on Archimedes’ Principle
for the given ice thickness. These curves represent the envelope of
possible albedo values. 

The net absorbed shortwave flux is :math:`F_{swabs} = \sum
(1-\alpha_j) F_{sw\downarrow}`, where the summation is over four
radiative categories (direct and diffuse visible, direct and diffuse
near infrared). The flux penetrating into the ice is :math:`I_0
= i_0 \, F_{swabs}`, where :math:`i_0 = 0.70 \, (1-f_{snow})`
for visible radiation and :math:`i_0 = 0` for near IR. Radiation
penetrating into the ice is attenuated according to Beer’s Law:

.. math::
   I(z) = I_0 \exp(-\kappa_i z),
   :label: Beers-law

where :math:`I(z)` is the shortwave flux that reaches depth :math:`z`
beneath the surface without being absorbed, and :math:`\kappa_i` is the
bulk extinction coefficient for solar radiation in ice, set to
:math:`1.4 \
{\mathrm m^{-1}}` for visible wavelengths :cite:`ESC95`. A
fraction :math:`\exp(-\kappa_i h_i)` of the penetrating solar radiation
passes through the ice to the ocean
(:math:`F_{sw\Downarrow}`). 

*Longwave radiation, turbulent fluxes*

While incoming shortwave and longwave radiation are obtained from the
atmosphere, outgoing longwave radiation and the turbulent heat fluxes
are derived quantities. Outgoing longwave takes the standard blackbody
form, :math:`F_{L\uparrow}=\epsilon\sigma
\left(T_{sf}^{K}\right)^4`, where :math:`\epsilon=0.95` is the
emissivity of snow or ice, :math:`\sigma` is the Stefan-Boltzmann
constant and :math:`T_{sf}^{K}` is the surface temperature in
Kelvin. (The longwave fluxes are partitioned such that
:math:`\epsilon F_{L\downarrow}` is absorbed at the surface, the
remaining :math:`\left(1-\epsilon\right)F_{L\downarrow}` being returned
to the atmosphere via :math:`F_{L\uparrow}`.) The sensible heat flux is
proportional to the difference between air potential temperature and the
surface temperature of the snow or snow-free ice,

.. math:: 
   F_s = C_s \left(\Theta_a - T_{sf}^K\right).
   :label: flux1

:math:`C_s` and :math:`C_l` (below) are nonlinear turbulent heat
transfer coefficients described in the :ref:`atmo` section. Similarly,
the latent heat flux is proportional to the difference between
:math:`Q_a` and the surface saturation specific humidity :math:`Q_{sf}`:

.. math::
   \begin{aligned}
   F_l&=& C_l\left(Q_a - Q_{sf}\right),\\
   Q_{sf}&=&(q_1 / \rho_a)  \exp(-q_2 / T_{sf}^K),\end{aligned}

where :math:`q_1 = 1.16378 \times 10^7 \, \mathrm{kg/m^3}`,
:math:`q_2 =
5897.8 \, \mathrm{K}`, :math:`T_{sf}^K` is the surface temperature in
Kelvin, and :math:`\rho_a` is the surface air density.

The net downward heat flux from the ice to the ocean is given by
:cite:`MM95`:

.. math::
   F_{bot} = -\rho_w c_w c_h u_* (T_w - T_f),
   :label: fbot

where :math:`\rho_w` is the density of seawater, :math:`c_w` is the
specific heat of seawater, :math:`c_h = 0.006` is a heat transfer
coefficient, :math:`u_*=\sqrt{\left|\vec{\tau}_w\right|/\rho_w}` is the
friction velocity, and :math:`T_w` is the sea surface temperature. A
minimum value of :math:`u_*` is available; we recommend
:math:`u_{*\min} = 5\times 10^{-4}` m/s, but the optimal value may
depend on the ocean forcing used and can be as low as 0.

:math:`F_{bot}` is limited by the total amount of heat available from
the ocean, :math:`F_{frzmlt}`. Additional heat,
:math:`F_{side}`, is used to melt the ice laterally following
:cite:`MP87` and :cite:`Steele92`.
:math:`F_{bot}` and the fraction of ice melting laterally are scaled so
that :math:`F_{bot} + F_{side} \ge F_{frzmlt}` in the case that
:math:`F_{frzmlt}<0` (melting; see
:ref:`thermo-growth`).

.. _thermo-temp:

New temperatures
~~~~~~~~~~~~~~~~

**Zero-layer thermodynamics** (``ktherm`` = 0)
An option for zero-layer thermodynamics :cite:`Semtner76` is
available in this version of Icepack by setting the namelist parameter
``ktherm`` to 0 and changing the number of ice layers, nilyr, in
**icepack\_domain\_size.F90** to 1. In the zero-layer case, the ice is
fresh and the thermodynamic calculations are much simpler than in the
other configurations, which we describe here.

**Bitz and Lipscomb thermodynamics** (``ktherm`` = 1)

The "BL99" thermodynamic sea ice model is based on
:cite:`MU71` and :cite:`BL99`, and is
described more fully in :cite:`Lipscomb98`. The vertical
salinity profile is prescribed and is unchanging in time. The snow is
assumed to be fresh, and the midpoint salinity :math:`S_{ik}` in each
ice layer is given by

.. math::
   S_{ik} = {1\over 2}S_{\max} [1-\cos(\pi z^{(\frac{a}{z+b})})],
   :label: salinity

where :math:`z \equiv (k-1/2)/N_i`, :math:`S_{\max} = 3.2` ppt, and
:math:`a=0.407` and :math:`b=0.573` are determined from a
least-squares fit to the salinity profile observed in multiyear sea
ice by :cite:`Schwarzacher59`. This profile varies from
:math:`S=0` at the top surface (:math:`z = 0`) to :math:`S=S_{\max}`
at the bottom surface (:math:`z=1`) and is similar to that used by
:cite:`MU71`. Equation :eq:`salinity` is fairly accurate
for ice that has drained at the top surface due to summer melting. It
is not a good approximation for cold first-year ice, which has a more
vertically uniform salinity because it has not yet drained. However,
the effects of salinity on heat capacity are small for temperatures
well below freezing, so the salinity error does not lead to
significant temperature errors.

*Temperature updates.* 

Given the temperatures :math:`T_{sf}^m`,
:math:`T_s^m`, and :math:`T_{ik}^m` at time \ :math:`m`, we solve a set
of finite-difference equations to obtain the new temperatures at
time \ :math:`m+1`. Each temperature is coupled to the temperatures of
the layers immediately above and below by heat conduction terms that are
treated implicitly. For example, the rate of change of :math:`T_{ik}`
depends on the new temperatures in layers :math:`k-1`, :math:`k`, and
:math:`k+1`. Thus we have a set of equations of the form

.. math::
   {\bf A} {\bf x} = {\bf b},
   :label: tridiag

where :math:`{\bf A}` is a tridiagonal matrix, :math:`{\bf x}` is a
column vector whose components are the unknown new temperatures, and
:math:`{\bf b}` is another column vector. Given :math:`{\bf A}` and
:math:`{\bf b}`, we can compute :math:`{\bf x}` with a standard
tridiagonal solver.

There are four general cases: (1) :math:`T_{sf} < 0^{\circ}C`, snow
present; (2) :math:`T_{sf} = 0^{\circ}C`, snow present;
(3) :math:`T_{sf} < 0^{\circ}C`, snow absent; and
(4) :math:`T_{sf} = 0^{\circ}C`, snow absent. For case 1 we have
one equation (the top row of the matrix) for the new surface
temperature, :math:`N_s` equations for the new snow temperatures, and
:math:`N_i` equations for the new ice temperatures. For cases 2 and 4 we
omit the equation for the surface temperature, which is held at , and
for cases 3 and 4 we omit the snow temperature equations. Snow is
considered absent if the snow depth is less than a user-specified
minimum value, ``hs_min``. (Very thin snow layers are still transported
conservatively by the transport modules; they are simply ignored by the
thermodynamics.)

The rate of temperature change in the ice interior is given by
:cite:`MU71`:

.. math::
   \rho_i c_i \frac{\partial T_i}{\partial t} =
    \frac{\partial}{\partial z} \left(K_i \frac{\partial T_i}{\partial z}\right)
    - \frac{\partial}{\partial z} [I_{pen}(z)],
   :label: ice-temp-change

where :math:`\rho_i = 917 \ \mathrm {kg/m^{3}}` is the sea ice density
(assumed to be uniform), :math:`c_i(T,S)` is the specific heat of sea
ice, :math:`K_i(T,S)` is the thermal conductivity of sea ice,
:math:`I_{pen}` is the flux of penetrating solar radiation at
depth :math:`z`, and :math:`z` is the vertical coordinate, defined to be
positive downward with :math:`z = 0` at the top surface. If ``shortwave`` =
‘default’, the penetrating radiation is given by Beer’s Law:

.. math:: 
   I_{pen}(z) = I_0 \exp(-\kappa_i z),

where :math:`I_0` is the penetrating solar flux at the top ice surface
and :math:`\kappa_i` is an extinction coefficient. If ``shortwave`` =
‘dEdd’, then solar absorption is computed by the Delta-Eddington scheme.

The specific heat of sea ice is given to an excellent approximation by
:cite:`Ono67`

.. math::
   c_i(T,S) = c_0 + \frac{L_0 \mu S}{T^2},
   :label: heat-capacity

where :math:`c_0 = 2106` J/kg/deg is the specific heat of fresh ice at
, :math:`L_0 = 3.34 \times 10^5` J/kg is the latent heat of fusion of
fresh ice at , and :math:`\mu = 0.054` deg/ppt is the (liquidus) ratio
between the freezing temperature and salinity of brine.

Following :cite:`Untersteiner64` and
:cite:`MU71`, the standard thermal conductivity
(``conduct`` = ‘MU71’) is given by

.. math::
   K_i(T,S) = K_0 + \frac{\beta S}{T},
   :label: conductivity

where :math:`K_0 = 2.03` W/m/deg is the conductivity of fresh ice and
:math:`\beta = 0.13` W/m/ppt is an empirical constant. Experimental
results :cite:`TWMH01` suggest that Equation :eq:`conductivity` may
not be a good description of the thermal conductivity of sea ice. In
particular, the measured conductivity does not markedly decrease as
:math:`T` approaches :math:`0^{\circ}C`, but does decrease near the top surface
(regardless of temperature).

An alternative parameterization based on the "bubbly brine" model of
:cite:`PETB07` for conductivity is available
(``conduct`` = ‘bubbly’):

.. math::
    K_i={\rho_i\over\rho_0}\left(2.11-0.011T+0.09 S/T\right),
   :label: Pringle

where :math:`\rho_i` and :math:`\rho_0=917` kg/m :math:`^3` are
densities of sea ice and pure ice. Whereas the parameterization in
Equation :eq:`conductivity` asymptotes to a constant conductivity of
2.03 W m\ :math:`^{-1}` K :math:`^{-1}` with decreasing :math:`T`,
:math:`K_i` in Equation :eq:`Pringle` continues to increase with colder
temperatures.

The equation for temperature changes in snow is analogous to
Equation :eq:`ice-temp-change`, with :math:`\rho_s = 330` kg/m :math:`^3`,
:math:`c_s = c_0`, and :math:`K_s = 0.30` W/m/deg replacing the
corresponding ice values. If shortwave = ‘default’, then the penetrating
solar radiation is equal to zero for snow-covered ice, since most of the
incoming sunlight is absorbed near the top surface. If shortwave =
‘dEdd’, however, then :math:`I_{pen}` is nonzero in snow layers.

It is possible that more shortwave penetrates into an ice layer than is
needed to completely melt the layer, or else it causes the computed
temperature to be greater than the melting temperature, which until now
has caused the vertical thermodynamics code to abort. A parameter
``frac`` = 0.9 sets the fraction of the ice layer than can be melted through.
A minimum temperature difference for absorption of radiation is also
set, currently ``dTemp`` = 0.02 (K). The limiting occurs in
**icepack\_therm\_vertical.F90**, for both the default and delta Eddington
radiation schemes. If the available energy would melt through a layer,
then penetrating shortwave is first reduced, possibly to zero, and if
that is insufficient then the local conductivity is also reduced to
bring the layer temperature just to the melting point.

We now convert Equation :eq:`ice-temp-change` to finite-difference form. The
resulting equations are second-order accurate in space, except possibly
at material boundaries, and first-order accurate in time. Before writing
the equations in full we give finite-difference expressions for some of
the terms.

First consider the terms on the left-hand side of
Equation :eq:`ice-temp-change`. We write the time derivatives as

.. math::
   \frac{\partial T}{\partial t} =
      \frac{T^{m+1} - T^m}{\Delta t},

where :math:`T` is the temperature of either ice or snow and :math:`m`
is a time index. The specific heat of ice layer :math:`k` is
approximated as

.. math::
   c_{ik} = c_0 + \frac{L_0 \mu S_{ik}} {T_{ik}^m \, T_{ik}^{m+1}},
   :label: heat-capacity-fd

which ensures that energy is conserved during a change in temperature.
This can be shown by using Equation :eq:`heat-capacity` to integrate
:math:`c_i \, dT` from :math:`T_{ik}^m` to :math:`T_{ik}^{m+1}`; the
result is :math:`c_{ik}(T_{ik}^{m+1} - T_{ik}^m)`, where :math:`c_{ik}`
is given by Equation :eq:`heat-capacity-fd`. The specific heat is a nonlinear
function of :math:`T_{ik}^{m+1}`, the unknown new temperature. We can
retain a set of linear equations, however, by initially guessing
:math:`T_{ik}^{m+1} = T_{ik}^m` and then iterating the solution,
updating :math:`T_{ik}^{m+1}` in Equation :eq:`heat-capacity-fd` with each
iteration until the solution converges.

Next consider the first term on the right-hand side of
Equation :eq:`ice-temp-change`. The first term describes heat diffusion and is
discretized for a given ice or snow layer :math:`k` as

.. math::
   \frac{\partial}{\partial z} \left(K \frac{\partial T}{\partial z}\right) =
    \frac{1}{\Delta h} 
     \left[ {K_k^*(T_{k-1}^{m+1} - T_{k}^{m+1})} - K_{k+1}^*(T_{k}^{m+1} - T_{k+1}^{m+1}) \right],
   :label: ice-dT-dz

where :math:`\Delta h` is the layer thickness and :math:`K_{k}` is the
effective conductivity at the upper boundary of layer :math:`k`. This
discretization is centered and second-order accurate in space, except at
the boundaries. The flux terms on the right-hand side (RHS) are treated
implicitly; i.e., they depend on the temperatures at the new time
:math:`m+1`. The resulting scheme is first-order accurate in time and
unconditionally stable. The effective conductivity :math:`K^*` at the
interface of layers :math:`k-1` and :math:`k` is defined as

.. math:: 
   K_k^* = {2K_{k-1}K_k\over{K_{k-1}h_k + K_k h_{k-1}}},

which reduces to the appropriate values in the limits
:math:`K_k \gg K_{k-1}` (or vice versa) and :math:`h_k \gg h_{k-1}` (or
vice versa). The effective conductivity at the top (bottom) interface of
the ice-snow column is given by :math:`K^*=2K/\Delta h`, where :math:`K`
and :math:`\Delta h` are the thermal conductivity and thickness of the
top (bottom) layer. The second term on the RHS of
Equation :eq:`ice-temp-change` is discretized as

.. math:: 
   {\partial\over\partial z}\left[I_{pen}(z)\right] = I_0{{\tau_{k-1}-\tau_k}\over \Delta h} = {I_k\over\Delta h}

where :math:`\tau_k` is the fraction of the penetrating solar radiation
:math:`I_0` that is transmitted through layer :math:`k` without being
absorbed.

We now construct a system of equations for the new temperatures. For
:math:`T_{sf}<0^{\circ}C` we require

.. math::
   F_0 = F_{ct},
   :label: top-surface

where :math:`F_{ct}` is the conductive flux from the top surface to the
ice interior, and both fluxes are evaluated at time :math:`m+1`.
Although :math:`F_0` is a nonlinear function of :math:`T_{sf}`,
we can make the linear approximation

.. math::
   F_0^{m+1} = F_0^* + \left( \frac{dF_0}{dT_{sf}} \right)^* \,
                              (T_{sf}^{m+1} - T_{sf}^*),

where :math:`T_{sf}^*` is the surface temperature from the
most recent iteration, and :math:`F_0^*` and
:math:`(dF_0/dT_{sf})^*` are functions of
:math:`T_{sf}^*`. We initialize
:math:`T_{sf}^* = T_{sf}^m` and update it with each
iteration. Thus we can rewrite Equation :eq:`top-surface` as

.. math::
   F_0^* + \left(\frac{dF_0}{dT_{sf}}\right)^* \, (T_
   {sf}^{m+1} - T_{sf}^*) =    K_1^* (T_{sf}^{m+1} - T_1^{m+1}),

Rearranging terms, we obtain

.. math::
   \left[ \left(\frac{dF_0}{dT_{sf}}\right)^* - K_1^* \right]
   T_{sf}^{m+1} +  K_1^* T_1^{m+1} =
   \left(\frac{dF_0}{dT_{sf}}\right)^* \, T_{sf}^* - F_0^*,
   :label: surface-case1

the first equation in the set of equations :eq:`tridiag`. The
temperature change in ice/snow layer :math:`k` is

.. math::
   \rho_k c_k \frac{(T_k^{m+1} - T_k^m)}{\Delta t} =
      \frac{1}{\Delta h_k} [K_k^*    (T_{k-1}^{m+1} - T_k^{m+1})
                   - K_{k+1}(T_k^{m+1} - T_{k+1}^{m+1})],
   :label: case1-prelim

where :math:`T_0 = T_{sf}` in the equation for layer 1. In
tridiagonal matrix form, Equation :eq:`case1-prelim` becomes

.. math::
   -\eta_k K_k T_{k-1}^{m+1} + \left[ 1 + \eta_k(K_k+K_{k+1}) \right]T_k^{m+1} -\eta_k K_{k+1} T_{k+1}^{m+1} = T_k^m + \eta_k I_k,
   :label: tridiag-form

where :math:`\eta_k = \Delta t/(\rho_k c_k \Delta h_k)`. In the
equation for the bottom ice layer, the temperature at the ice–ocean
interface is held fixed at :math:`T_f`, the freezing temperature of the
mixed layer; thus the last term on the LHS is known and is moved to the
RHS. If :math:`T_{sf} = 0^{\circ}C` , then there is no surface flux
equation. In this case the first equation in Equation :eq:`tridiag` is similar
to Equation :eq:`tridiag-form`, but with the first term on the LHS moved to the
RHS.

These equations are modified if :math:`T_{sf}` and
:math:`F_{ct}` are computed within the atmospheric model and
passed to the host sea ice model (calc\_Tsfc = false; see :ref:`atmo`). In this case there
is no surface flux equation. The top layer temperature is computed by an
equation similar to Equation :eq:`tridiag-form` but with the first term on the
LHS replaced by :math:`\eta_1 F_{ct}` and moved to the RHS. The
main drawback of treating the surface temperature and fluxes explicitly
is that the solution scheme is no longer unconditionally stable.
Instead, the effective conductivity in the top layer must satisfy a
diffusive CFL condition:

.. math:: 
   K^* \le {\rho ch \over \Delta t}.

For thin layers and typical coupling intervals (:math:`\sim 1` hr),
:math:`K^*` may need to be limited before being passed to the atmosphere
via the coupler. Otherwise, the fluxes that are returned to the host sea ice model may
result in oscillating, highly inaccurate temperatures. The effect of
limiting is to treat the ice as a poor heat conductor. As a result,
winter growth rates are reduced, and the ice is likely to be too thin
(other things being equal). The values of ``hs_min`` and :math:`\Delta t`
must therefore be chosen with care. If ``hs_min`` is too small, frequent
limiting is required, but if ``hs_min`` is too large, snow will be ignored
when its thermodynamic effects are significant. Likewise, infrequent
coupling requires more limiting, whereas frequent coupling is
computationally expensive.

This completes the specification of the matrix equations for the four
cases. We compute the new temperatures using a tridiagonal solver. After
each iteration we check to see whether the following conditions hold:

#. :math:`T_{sf} \leq 0^{\circ}C`.

#. The change in :math:`T_{sf}` since the previous iteration is
   less than a prescribed limit, :math:`\Delta T_{\max}`.

#. :math:`F_0 \geq F_{ct}`. (If :math:`F_0 < F_{ct}`, ice would be
   growing at the top surface, which is not allowed.)

#. The rate at which energy is added to the ice by the external fluxes
   equals the rate at which the internal ice energy is changing, to
   within a prescribed limit :math:`\Delta F_{\max}`.

We also check the convergence rate of :math:`T_{sf}`. If :math:`T_{sf}`
is oscillating and failing to converge, we average temperatures from
successive iterations to improve convergence. When all these conditions
are satisfied—usually within two to four iterations for
:math:`\Delta T_{\max} \approx 0.01^{\circ}C` and :math:`\Delta F_{max}
\approx 0.01 \ \mathrm{W/m^2}`—the calculation is complete.

To compute growth and melt rates (:ref:`thermo-growth`,
we derive expressions for the enthalpy :math:`q`. The enthalpy of snow
(or fresh ice) is given by

.. math::
    q_s(T) = - \rho_s (-c_0 T + L_0).

Sea ice enthalpy is more complex, because of brine pockets whose
salinity varies inversely with temperature. Since the salinity is
prescribed, there is a one-to-one relationship between temperature and
enthalpy. The specific heat of sea ice, given by
Equation :eq:`heat-capacity`, includes not only the energy needed to warm or
cool ice, but also the energy used to freeze or melt ice adjacent to
brine pockets. Equation :eq:`heat-capacity` can be integrated to
give the energy :math:`\delta_e` required to raise the temperature of
a unit mass of sea ice of salinity :math:`S` from :math:`T` to
:math:`T^\prime`:

.. math::
   \delta_e(T,T^\prime) = c_0 (T^\prime - T)
             + L_0 \mu S \left(\frac{1}{T} - \frac{1}{T^\prime}\right).

If we let :math:`T^\prime = T_{m} \equiv -\mu S`, the temperature at
which the ice is completely melted, we have

.. math::
   \delta_e(T,T_m) = c_0 (T_{m} - T)
                   + L_0 \left(1 - \frac{T_m}{T}\right).

Multiplying by :math:`\rho_i` to change the units from
:math:`\mathrm {J/kg}` to :math:`\mathrm {J/m^{3}}` and adding a term
for the energy needed to raise the meltwater temperature to , we
obtain the sea ice enthalpy:

.. math::
   q_i(T,S) = - \rho_i \left[ c_0(T_m-T)
              + L_0 \left(1-\frac{T_m}{T}\right) - c_w T_m.
                     \right]
   :label: ice-enthalpy

Note that Equation :eq:`ice-enthalpy` is a quadratic equation in :math:`T`.
Given the layer enthalpies we can compute the temperatures using the
quadratic formula:

.. math:: 
   T = \frac{-b - \sqrt{b^2 - 4 a c}} {2 a},

where

.. math::
   \begin{aligned}
   a & = & c_0,  \\
   b & = & (c_w - c_0) \, T_m - \frac{q_i}{\rho_i} - L_0, \\
   c & = & L_0 T_m.\end{aligned}

The other root is unphysical.

**Mushy thermodynamics** (``ktherm`` = 2)

The "mushy" thermodynamics option treats the sea ice as a mushy layer
:cite:`FUWW06` in which the ice is assumed to be composed
of microscopic brine inclusions surrounded by a matrix of pure water
ice. Both enthalpy and salinity are prognostic variables. The size of
the brine inclusions is assumed to be much smaller than the size of
the ice layers, allowing a continuum approximation: a bulk sea-ice
quantity is taken to be the liquid-fraction-weighted average of that
quantity in the ice and in the brine.

*Enthalpy and mushy physics.* 

The mush enthalpy, :math:`q`, is related
to the temperature, :math:`T`, and the brine volume, :math:`\phi`, by

.. math::
   \begin{aligned}
   q =& \phi q_{br} &+\, (1-\phi) q_{i}
   =& \phi \rho_{w} c_{w} T &+\, (1-\phi) (\rho_i c_i T - \rho_i L_0) 
   \end{aligned}
   :label: enth-def

where :math:`q_{br}` is the brine enthalpy, :math:`q_i` is the pure ice
enthalpy, :math:`\rho_i` and :math:`c_i` are density and heat capacity
of the ice, :math:`\rho_{w}` and :math:`c_{w}` are density and heat
capacity of the brine and :math:`L_0` is the latent heat of melting of
pure ice. We assume that the specific heats of the ice and brine are
fixed at the values of cp\_ice and cp\_ocn, respectively. The enthalpy
is the energy required to raise the temperature of the sea ice to ,
including both sensible and latent heat changes. Since the sea ice
contains salt, it usually will be fully melted at a temperature below
:math:`0^{\circ}C`.
Equations :eq:`ice-enthalpy` and :eq:`enth-def` are
equivalent except for the density used in the term representing the
energy required to bring the melt water temperature to (:math:`\rho_i`
and :math:`\rho_w` in equations :eq:`ice-enthalpy` and
:eq:`enth-def`, respectively).

The liquid fraction, :math:`\phi`, of sea ice is given by

.. math:: 
   \phi = \frac{S}{S_{br}}

where the brine salinity, :math:`S_{br}`, is given by the liquidus
relation using the ice temperature.

Within the parameterizations of brine drainage the brine density is a
function of brine salinity :cite:`Notz05`:

.. math:: 
   \rho(S_{br})=1000.3 + 0.78237 S_{br} + 2.8008\times10^{-4} S_{br}^2.

Outside the parameterizations of brine drainage the densities of brine
and ice are fixed at the values of :math:`\rho_w` and :math:`\rho_i`,
respectively.

The permeability of ice is computed from the liquid fraction as in
:cite:`GEHMPZ07`:


.. math:: 
   \Pi(\phi) = 3\times10^{-8} (\phi - \phi_\Pi)^3

where :math:`\phi_\Pi` is 0.05.

The liquidus relation used in the mushy layer module is based on
observations of :cite:`Assur58`. A piecewise linear
relation can be fitted to observations of Z (the ratio of mass of salt
(in g) to mass of pure water (in kg) in brine) to the melting
temperature: :math:`Z = aT + b`. Salinity is the mass of salt (in g) per
mass of brine (in kg) so is related to Z by

.. math:: 
   \frac{1}{S} = \frac{1}{1000} + \frac{1}{Z}.

The data is well fitted with two linear regions,

.. math:: 
   S_{br} = \frac{(T+J_1)}{(T/1000 + L_1)}l_0 + \frac{(T+J_2)}{(T/1000 + L_2)}(1-l_0)

where

.. math::
   l_0 = \left\lbrace \begin{array}{lcl}
   1 & \mathrm{if} & T \ge T_0 \\
   0 & \mathrm{if} & T <  T_0\end{array} \right.,

.. math:: 
   J_{1,2} = \frac{b_{1,2}}{a_{1,2}},

.. math:: 
   L_{1,2} =  \frac{(1 + b_{1,2}/1000)}{a_{1,2}}.

:math:`T_0` is the temperature at which the two linear regions meet.
Fitting to the data, :math:`T_0=-7.636^\circ`\ C,
:math:`a_1=-18.48 \;\mathrm{g} \;\mathrm{kg}^{-1} \;\mathrm{K}^{-1}`,
:math:`a_2=-10.3085\;\mathrm{g} \;\mathrm{kg}^{-1} \;\mathrm{K}^{-1}`,
:math:`b_1=0` and :math:`b_2=62.4 \;\mathrm{g}\;\mathrm{kg}^{-1}`.

*Two stage outer iteration.* 

As for the BL99 thermodynamics
:cite:`BL99` there are two qualitatively different
situations that must be considered when solving for the vertical
thermodynamics: the surface can be melting and at the melting
temperature, or the surface can be colder than the melting temperature
and not melting. In the BL99 thermodynamics these two situations were
treated within the same iterative loop, but here they are dealt with
separately. If at the beginning of the time step the ice surface is cold
and not melting, we solve the ice temperatures assuming that this is
also true at the end of the time step. Once we have solved for the new
temperatures we test to see if the answer is consistent with this
assumption. If the surface temperature is below the melting temperature
then we have found the appropriate consistent solution. If the surface
is above the melting temperature at the end of the initial solution
attempt, we recalculate the new temperatures assuming the surface
temperature is fixed at the melting temperature. Alternatively if the
surface is at the melting temperature at the start of a time step, we
assume initially that this is also the case at the end of the time step,
solve for the new temperatures and then check that the surface
conductive heat flux is less than the surface atmospheric heat flux as
is required for a melting surface. If this is not the case, the
temperatures are recalculated assuming the surface is colder than
melting. We have found that solutions of the temperature equations that
only treat one of the two qualitatively different solutions at a time
are more numerically robust than if both are solved together. The
surface state rarely changes qualitatively during the solution so the
method is also numerically efficient.

*Temperature updates.* 

During the calculation of the new temperatures
and salinities, the liquid fraction is held fixed at the value from the
previous time step. Updating the liquid fraction during the Picard
iteration described below was found to be numerically unstable. Keeping
the liquid fraction fixed drastically improves the numerical stability
of the method without significantly changing the solution.

Temperatures are calculated in a similar way to BL99 with an outer
Picard iteration of an inner tridiagonal matrix solve. The conservation
equation for the internal ice temperatures is

.. math:: 
   \frac{\partial{q}}{\partial{t}}=\frac{\partial{}}{\partial{z}} \left( K \frac{\partial{T}}{\partial{z}} \right) + w \frac{\partial{q_{br}}}{\partial{z}} + F

where :math:`q` is the sea ice enthalpy, :math:`K` is the bulk thermal
conductivity of the ice, :math:`w` is the vertical Darcy velocity of the
brine, :math:`q_{br}` is the brine enthalpy and :math:`F` is the
internally absorbed shortwave radiation. The first term on the right
represents heat conduction and the second term represents the vertical
advection of heat by gravity drainage and flushing.

The conductivity of the mush is given by

.. math:: 
   K = \phi K_{br} + (1-\phi) K_{i}

where :math:`K_i = 2.3` Wm:math:`^{-1}`K:math:`^{-1}` is the
conductivity of pure ice and
:math:`K_{br}=0.5375` Wm:math:`^{-1}`K:math:`^{-1}` is the
conductivity of the brine. The thermal conductivity of brine is a
function of temperature and salinity, but here we take it as a constant
value for the middle of the temperature range experienced by sea ice,
:math:`-10^\circ`\ C :cite:`SP86`, assuming the brine
liquidus salinity at :math:`-10^\circ`\ C.

We discretize the terms that include temperature in the heat
conservation equation as

.. math::
   \frac{q^{t}_k - q^{t_0}_k}{\Delta t} = \frac{\frac{K^*_{k+1}}{\Delta z^\prime_{k+1}} (T^t_{k+1} - T^t_k) - \frac{K^*_k}{\Delta z^\prime_k} (T^t_k - T^t_{k-1})}{\Delta h}
   :label: mushyheat

where the superscript signifies whether the quantity is evaluated at
the start (:math:`t_0`) or the end (:math:`t`) of the time step and the
subscript indicates the vertical layer. Writing out the temperature
dependence of the enthalpy term we have

.. math:: 
   \frac{\left(\phi (c_w \rho_w - c_i \rho_i) + c_i \rho_i\right) T^t_k - (1-\phi) \rho_i L - q^{t_0}_k}{\Delta t} = \frac{ \frac{K^*_{k+1}}{\Delta z^\prime_{k+1}} (T^t_{k+1} - T^t_k) - \frac{K^*_k}{\Delta z^\prime_k} (T^t_k - T^t_{k-1})}{\Delta h}.

The mush thermal conductivities are fixed at the start of the timestep.
For the lowest ice layer :math:`T_{k+1}` is replaced with
:math:`T_{bot}`, the temperature of the ice base. :math:`\Delta h` is
the layer thickness and :math:`z^\prime_k` is the distance between the
:math:`k-1` and :math:`k` layer centers.

Similarly, for the snow layer temperatures we have the following
discretized equation:

.. math::
   \frac{c_i \rho_s T^t_k - \rho_s L_0- q^{t_0}_k}{\Delta t} = \frac{ \frac{K^*_{k+1}}{\Delta z^\prime_{k+1}} (T^t_{k+1} - T^t_k) - \frac{K^*_k}{\Delta z^\prime_k} (T^t_k - T^t_{k-1})}{\Delta h}.

For the upper-most layer (either ice layer or snow layer if it present)
:math:`T_{k-1}` is replaced with :math:`T_{sf}`, the temperature of the
surface.

If the surface is colder than the melting temperature then we also have
to solve for the surface temperature, :math:`T_{sf}`. Here we follow the
methodology of BL99 described above.

These discretized temperature equations form a tridiagional matrix for
the new temperatures and are solved with a standard tridiagonal solver.
A Picard iteration is used to incorporate nonlinearity in the equations.
The surface heat flux is a function of surface temperature and with each
iteration, the surface heat flux is calculated with the new surface
temperature until convergence is achieved. Convergence normally occurs
after a few iterations once the temperature changes during an iteration
fall below :math:`5\times10^{-4}\;^\circ\mathrm{C}` and the energy
conservation error falls below 0.9``ferrmax``.

*Salinity updates.* 

Several physical processes alter the sea ice bulk
salinity. New ice forms with the salinity of the sea water from which it
formed. Gravity drainage reduces the bulk salinity of newly formed sea
ice, while flushing of melt water through the ice also alters the
salinity profile.

The salinity equation takes the form

.. math:: 
   \frac{\partial{S}}{\partial{t}} = w \frac{\partial{S_{br}}}{\partial{z}} + G

where :math:`w` is a vertical Darcy velocity and :math:`G` is a source
term. The right-hand side depends indirectly on the bulk salinity
through the liquid fraction (:math:`S = \phi S_{br}`). Since
:math:`\phi` is fixed for the time step, we solve the salinity equation
explicitly after the temperature equation is solved.

A. Gravity drainage. Sea ice initially retains all the salt present in
the sea water from which it formed. Cold temperatures near the top
surface of forming sea ice result in higher brine salinities there,
because the brine is always at its melting temperature. This colder,
saltier brine is denser than the underlying sea water and the brine
undergoes convective overturning with the ocean. As the dense, cold
brine drains out of the ice, it is replaced by fresher seawater,
lowering the bulk salinity of the ice. Following
:cite:`THB13`, gravity drainage is assumed to occur as two
simultaneously operating modes: a rapid mode operating principally near
the ice base and a slow mode occurring everywhere.

*Rapid drainage* takes the form of a vertically varying upward Darcy
flow. The contribution to the bulk salinity equation for the rapid mode
is

.. math:: 
   \left. \frac{\partial{S}}{\partial{t}} \right|_{rapid} = w(z) \frac{\partial{S_{br}}}{\partial{z}}

where :math:`S` is the bulk salinity and :math:`B_{br}` is the brine
salinity, specified by the liquidus relation with ice temperature. This
equation is discretized using an upwind advection scheme,

.. math:: 
   \frac{S_k^t - S_k^{t_0}}{\Delta t} = w_k \frac{S_{br k+1} - S_{br k}}{\Delta z}.

The upward advective flow also carries heat, contributing a term to the
heat conservation Equation :eq:`mushyheat`,

.. math:: 
   \left. \frac{\partial{q}}{\partial{t}}  \right|_{rapid} = w(z) \frac{\partial{q_{br}}}{\partial{z}}

where :math:`q_{br}` is the brine enthalpy. This term is discretized as

.. math:: 
   \left.\frac{q_k^t - q_k^{t_0}}{\Delta t}  \right|_{rapid} = w_k \frac{q_{br\,k+1} - q_{br\,k}}{\Delta z}.

.. math:: 
   w_k = \max_{j=k,n}\left(\tilde{w}_j \right)

where the maximum is taken over all the ice layers between layer
:math:`k` and the ice base. :math:`\tilde{w}_j` is given by

.. math::
   \tilde{w}(z) = w \left( \frac{Ra(z) - Ra_c}{Ra(z)} \right).
   :label: mushyvel

where :math:`Ra_c` is a critical Rayleigh number and :math:`Ra(z)` is
the local Rayleigh number at a particular level,

.. math:: 
   Ra(z) = \frac{g \Delta \rho \Pi (h-z)}{\kappa \eta}

where :math:`\Delta \rho` is the difference in density between the
brine at :math:`z` and the ocean, :math:`\Pi` is the minimum
permeability between :math:`z` and the ocean, :math:`h` is the ice
thickness, :math:`\kappa` is the brine thermal diffusivity and
:math:`\eta` is the brine dynamic viscosity. Equation ([eq:mushyvel])
reduces the flow rate for Rayleigh numbers below the critical Rayleigh
number.

The unmodified flow rate, :math:`w`, is determined from a hydraulic
pressure balance argument for upward flow through the mush and returning
downward flow through ice free channels:

.. math:: 
   w(z) \Delta x^2=A_m \left(-\frac{\Delta P}{l} + B_m\right)

where

.. math::
   \begin{aligned}
   \frac{\Delta P}{l} &=& \frac{A_p B_p + A_mB_m}{A_m+A_p},\\
   A_m&=& \frac{\Delta x^2}{\eta} \frac{n}{\sum^n_{k=1}\frac{1}{\Pi(k)}},\\
   B_m&=& -\frac{g}{n}\sum_{k=1}^n \rho(k),\\
   A_p&=& \frac{\pi a^4}{8 \eta},\\
   B_p&=& -\rho_p g.\end{aligned}

There are three tunable parameters in the above parameterization,
:math:`a`, the diameter of the channel, :math:`\Delta x`, the horizontal
size of the mush draining through each channel, and :math:`Ra_c`, the
critical Rayleigh number. :math:`\rho_p` is the density of brine in the
channel which we take to be the density of brine in the mush at the
level that the brine is draining from. :math:`l` is the thickness of
mush from the ice base to the top of the layer in question. We assume
that :math:`\Delta x` is proportional to :math:`l` so that
:math:`\Delta x = 2 \beta l`. :math:`a` (``a_rapid_mode``), :math:`\beta`
(``aspect_rapid_mode``) and :math:`Ra_c` (``Ra_c_rapid_mode``) are all
namelist parameters with default values of :math:`0.5\;\mathrm{mm}`, 1
and 10, respectively. The value :math:`\beta=1` gives a square aspect
ratio for the convective flow in the mush.

The *slow drainage* mode takes the form of a simple relaxation of bulk
salinity:

.. math:: 
   \left.\frac{\partial{S(z)}}{\partial{t}}\right|_{slow} = -\lambda (S(z) - S_c).

The decay constant, :math:`\lambda`, is modeled as

.. math:: 
   \lambda =S^\ast \max \left( \frac{T_{bot} - T_{sf}}{h},0\right)

where :math:`S^\ast` is a tuning parameter for the drainage strength,
:math:`T_{bot}` is the basal ice temperature, :math:`T_{sf}` is the
upper surface temperature and :math:`h` is the ice thickness. The bulk
salinity relaxes to a value, :math:`S_c(z)`, given by

.. math:: 
   S_c(z) = \phi_c S_{br}(z)

where :math:`S_{br}(z)` is the brine salinity at depth :math:`z` and
:math:`\phi_c` is a critical liquid fraction. Both :math:`S^\ast` and
:math:`\phi_c` are namelist parameters,
``dSdt_slow_mode`` :math:`=1.5\times10^{-7}\;\mathrm{m}\;\mathrm{s}^{-1}\;\mathrm{K}^{-1}`
and ``phi_c_slow_mode`` :math:`=0.05`.

B. Downwards flushing. Melt pond water drains through sea ice and
flushes out brine, reducing the bulk salinity of the sea ice. This is
modeled with the mushy physics option as a vertical Darcy flow through
the ice that affects both the enthalpy and bulk salinity of the sea ice:

.. math:: 
   \left.\frac{\partial{q}}{\partial{t}}\right|_{flush} = w_f \frac{\partial{q_{br}}}{\partial{z}}

.. math:: 
   \left.\frac{\partial{S}}{\partial{t}} \right|_{flush}= w_f \frac{\partial{S_{br}}}{\partial{z}}

These equations are discretized with an upwind advection scheme. The
flushing Darcy flow, :math:`w_f`, is given by

.. math:: 
   w_f=\frac{\overline{\Pi} \rho_w g \Delta h}{h \eta},

where :math:`\overline{\Pi}` is the harmonic mean of the ice layer
permeabilities and :math:`\Delta h` is the hydraulic head driving melt
water through the sea ice. It is the difference in height between the
top of the melt pond and sea level.

*Basal boundary condition.* 

In traditional Stefan problems the ice
growth rate is calculated by determining the difference in heat flux on
either side of the ice/ocean interface and equating this energy
difference to the latent heat of new ice formed. Thus,

.. math::
   (1-\phi_i) L_0 \rho_i \frac{\partial{h}}{\partial{t}} = K \left. \frac{\partial{T}}{\partial{z}} \right|_i - K_w \left. \frac{\partial{T}}{\partial{z}} \right|_w
   :label: growth-stefan

where :math:`(1-\phi_i)` is the solid fraction of new ice formed and
the right hand is the difference in heat flux at the ice–ocean interface
between the ice side and the ocean side of the interface. However, with
mushy layers there is usually no discontinuity in solid fraction across
the interface, so :math:`\phi_i=1` and Equation :eq:`growth-stefan`
cannot be used explicitly. To circumvent this problem we set the
interface solid fraction to be 0.15, a value that reproduces
observations. :math:`\phi_i` is a namelist parameter (``phi_i_mushy`` =
0.85). The basal ice temperature is set to the liquidus temperature
:math:`T_f` of the ocean surface salinity.

*Tracer consistency.* 

In order to ensure conservation of energy and salt
content, the advection routines will occasionally limit changes to
either enthalpy or bulk salinity. The mushy thermodynamics routine
determines temperature from both enthalpy and bulk salinity. Since the
limiting changes performed in the advection routine are not applied
consistently (from a mushy physics point of view) to both enthalpy and
bulk salinity, the resulting temperature may be changed to be greater
than the limit allowed in the thermodynamics routines. If this situation
is detected, the code corrects the enthalpy so the temperature is below
the limiting value. Conservation of energy is ensured by placing the
excess energy in the ocean, and the code writes a warning that this has
occurred to the diagnostics file. This situation only occurs with the
mushy thermodynamics, and it should only occur very infrequently and
have a minimal effect on results. The addition of the heat to the ocean
may reduce ice formation by a small amount afterwards.

.. _thermo-growth:

Growth and melting
~~~~~~~~~~~~~~~~~~

Melting at the top surface is given by

.. math::
   q \, \delta h = \left\{\begin{array}{ll}
   (F_0-F_{ct}) \, \Delta t & \mbox{if $F_0>F_{ct}$} \\
   0                   & \mbox{otherwise}
            \end{array}
            \right.
   :label: top-melting


where :math:`q` is the enthalpy of the surface ice or snow layer [1]_
(recall that :math:`q < 0`) and :math:`\delta h` is the change in
thickness. If the layer melts completely, the remaining flux is used to
melt the layers beneath. Any energy left over when the ice and snow are
gone is added to the ocean mixed layer. Ice cannot grow at the top
surface due to conductive fluxes; however, snow–ice can form. New
snowfall is added at the end of the thermodynamic time step.

Growth and melting at the bottom ice surface are governed by

.. math::
   q \, \delta h = (F_{cb} - F_{bot}) \,
   \Delta t,
   :label: bottom-melting

where :math:`F_{bot}` is given by Equation :eq:`fbot` and :math:`F_{cb}` is the
conductive heat flux at the bottom surface:

.. math:: 
   F_{cb} =   \frac{K_{i,N+1}}{\Delta h_i}  (T_{iN} - T_f).

If ice is melting at the bottom surface, :math:`q`
in Equation :eq:`bottom-melting` is the enthalpy of the bottom ice layer. If
ice is growing, :math:`q` is the enthalpy of new ice with temperature
:math:`T_f` and salinity :math:`S_{max}` (``ktherm`` = 1) or ocean surface
salinity (``ktherm`` = 2). This ice is added to the bottom layer.

In general, frazil ice formed in the ocean is added to the thinnest ice
category. The new ice is grown in the open water area of the grid cell
to a specified minimum thickness; if the open water area is nearly zero
or if there is more new ice than will fit into the thinnest ice
category, then the new ice is spread over the entire cell.

If the latent heat flux is negative (i.e., latent heat is transferred
from the ice to the atmosphere), snow or snow-free ice sublimates at the
top surface. If the latent heat flux is positive, vapor from the
atmosphere is deposited at the surface as snow or ice. The thickness
change of the surface layer is given by

.. math:: 
   (\rho L_v - q) \delta h = F_l \Delta t,
   :label: latent-heat

where :math:`\rho` is the density of the surface material (snow or
ice), and :math:`L_v = 2.501 \times 10^6 \ \mathrm{J/kg}` is the latent
heat of vaporization of liquid water at . Note that :math:`\rho L_v` is
nearly an order of magnitude larger than typical values of :math:`q`.
For positive latent heat fluxes, the deposited snow or ice is assumed to
have the same enthalpy as the existing surface layer.

After growth and melting, the various ice layers no longer have equal
thicknesses. We therefore adjust the layer interfaces, conserving
energy, so as to restore layers of equal thickness
:math:`\Delta h_i = h_i / N_i`. This is done by computing the overlap
:math:`\eta_{km}` of each new layer :math:`k` with each old layer
:math:`m`:

.. math:: 
   \eta_{km} = \min(z_m,z_k) - \max(z_{m-1},z_{k-1}),

where :math:`z_m` and :math:`z_k` are the vertical coordinates of the
old and new layers, respectively. The enthalpies of the new layers are

.. math:: 
   q_k = \frac{1}{\Delta h_i} \sum_{m=1}^{N_i} \eta_{km} q_m.

Lateral melting is accomplished by multiplying the state variables by
:math:`1-r_{side}`, where :math:`r_{side}` is the fraction of ice melted
laterally :cite:`MP87,Steele92`, and adjusting the ice
energy and fluxes as appropriate. We assume a floe diameter of 300 m.

*Snow ice formation.* 

At the end of the time step we check whether the
snow is deep enough to lie partially below the surface of the ocean
(freeboard). From Archimedes’ principle, the base of the snow is at sea
level when

.. math:: 
   \rho_i h_i + \rho_s h_s = \rho_w h_i.

Thus the snow base lies below sea level when

.. math:: 
   h^* \equiv h_s - \frac {(\rho_w-\rho_i) h_i}{\rho_s} > 0.

In this case, for ``ktherm`` = 1 (BL99) we raise the snow base to sea level
by converting some snow to ice:

.. math::
   \begin{aligned}
   \delta h_s & = & \frac{-\rho_i h^*}{\rho_w},  \\
   \delta h_i & = & \frac{\rho_s h^*}{\rho_w}.\end{aligned}

In rare cases this process can increase the ice thickness
substantially. For this reason snow–ice conversions are postponed until
after the remapping in thickness space
(:ref:`itd-trans`), which assumes that ice growth during
a single time step is fairly small.

For ``ktherm`` = 2 (mushy), we model the snow–ice formation process as
follows: If the ice surface is below sea level then we replace some snow
with the same thickness of sea ice. The thickness change chosen is that
which brings the ice surface to sea level. The new ice has a porosity of
the snow, which is calculated as

.. math:: 
   \phi = 1 - \frac{\rho_s}{\rho_i}

where :math:`\rho_s` is the density of snow and :math:`\rho_i` is the
density of fresh ice. The salinity of the brine occupying the above
porosity within the new ice is taken as the sea surface salinity. Once
the new ice is formed, the vertical ice and snow layers are regridded
into equal thicknesses while conserving energy and salt.

.. [1]
   The mushy thermodynamics option does not include the enthalpy
   associated with raising the meltwater temperature to in these
   calculations, unlike BL99, which does include it. This extra heat is
   returned to the ocean (or the atmosphere, in the case of evaporation)
   with the melt water.

.. _ice-bgc:

Biogeochemistry
---------------

From: Nicole Jeffery, Scott Elliott, Elizabeth C. Hunke, William H. Lipscomb, and Adrian K. Turner
default aerosols from: David Baily, Marika Holland... others?

Aerosols
~~~~~~~~

Default Aerosols
****************

Aerosols may be deposited on the ice and gradually work their way
through it until the ice melts and they are passed into the ocean. They
are defined as ice and snow volume tracers (Eq. 15 and 16 in CICE.v5
documentation), with the snow and ice each having two tracers for each
aerosol species, one in the surface scattering layer (delta-Eddington
SSL) and one in the snow or ice interior below the SSL.

Rather than updating aerosols for each change to ice/snow thickness due
to evaporation, melting, snow-ice formation, etc., during the
thermodynamics calculation, these changes are deduced from the
diagnostic variables (melts, meltb, snoice, etc) in
**icepack\_aerosol.F90**. Three processes change the volume of ice or snow
but do not change the total amount of aerosol, thus causing the aerosol
concentration (the value of the tracer itself) to increase: evaporation,
snow deposition and basal ice growth. Basal and lateral melting remove
all aerosols in the melted portion. Surface ice and snow melt leave a
significant fraction of the aerosols behind, but they do "scavenge" a
fraction of them given by the parameter kscav = [0.03, 0.2, 0.02, 0.02,
0.01, 0.01] (only the first 3 are used in CESM, for their 3 aerosol
species). Scavenging also applies to snow-ice formation. When sea ice
ridges, a fraction of the snow on the ridging ice is thrown into the
ocean, and any aerosols in that fraction are also lost to the ocean.

As upper SSL or interior layers disappear from the snow or ice, aerosols
are transferred to the next lower layer, or into the ocean when no ice
remains. The atmospheric flux faero\_atm contains the rates of aerosol
deposition for each species, while faero\_ocn has the rate at which the
aerosols are transferred to the ocean.

The aerosol tracer flag tr\_aero must be set to true in **icepack\_in**, and
the number of aerosol species is set in **icepack.settings**; CESM uses 3.
Global diagnostics are available when print\_global is true, and history
variables include the mass density for each layer (snow and ice SSL and
interior), and atmospheric and oceanic fluxes, for each species.

Z-Aerosols
**********

zbgc\_colpkg offers an alternate scheme for aerosols in sea ice using
the brine motion based transport scheme of the biogeochemical tracers.
All vertically resolved biogeochemical tracers (z-tracers), including
zaerosols, have the potential to be atmospherically deposited onto the
snow or ice, scavenged during snow melt, and passed into the brine. The
mobile fraction (discussed in :ref:`mobile-and-stationary`) is
then transported via brine drainage processes
(Eq. :eq:`mobile-transport` in section :ref:`trans-bio-grid`) while a
stationary fraction (discussed in :ref:`mobile-and-stationary`)
adheres to the ice crystals. Snow deposition and the process of
scavenging aerosols during snow melt is consistent with the default
aerosol scheme, though parameters have been generalized to accomadate
potential atmospheric deposition for all z-tracers. For an example, see
the scavenging parameter kscavz for z-tracers defined in
**icepack\_zbgc\_shared**.

Within the snow, z-tracers are defined as concentrations in the snow
surface layer (:math:`h_{ssl}`) and the snow interior
(:math:`h_s-h_{ssl}`). The total snow content of z-tracers per ice area
per grid cell area, :math:`C_{snow}` is

.. math::
   C_{snow} = C_{ssl}h_{ssl} + C_{sint}(h_{s}-h_{ssl})

One major difference in how the two schemes model snow aerosol transport
is that the fraction scavenged from snow melt in the z-tracer scheme is
not immediately fluxed into the ocean, but rather, enters the ice as a
source of low salinity but potentially tracer rich brine. The snow melt
source is included as a surface flux condition in **icepack\_algae.F90**.

All the z-aerosols are nonreactive with the exception of the dust
aerosols. We assume that a small fraction of the dust flux into the ice
has soluble iron (dustFe\_sol in **icepack\_in**) and so is
passed to the dissolved iron tracer. The remaining dust passes through
the ice without reactions.

To use z-aerosols, tr\_zaero must be set to true in **icepack\_in**, and the
number of z-aerosol species is set in **icepack.settings**, TRZAERO. Note, the
default tracers tr\_aero must be false and NTRAERO in **icepack.settings**
should be 0. In addition, z-tracers and the brine height tracer must
also be active. These are set in **icepack\_in** with tr\_brine and
z\_tracer equal to true. In addition, to turn on the radiative coupling
between the aerosols and the Delta-Eddington radiative scheme, shortwave
must equal ’dEdd’ and dEdd\_algae must be true in **icepack\_in**.

.. _brine-ht:

Brine height
~~~~~~~~~~~~

The brine height, :math:`h_b`, is the distance from the ice-ocean
interface to the brine surface. When tr\_brine is set true in
**icepack\_in** and TRBRI is set equal to 1 in **icepack.settings**, the brine
surface can move relative to the ice surface. Physically, this occurs
when the ice is permeable and there is a nonzero pressure head: the
difference between the brine height and the equilibrium sea surface.
Brine height motion is computed in **icepack\_brine.F90** from thermodynamic
variables and the ice microstructural state
deduced from internal bulk salinities and temperature. This tracer is
required for the transport of vertically resolved biogeochemical tracers
and is closely coupled to the z-salinity prognostic salinity model.

Vertical transport processes are, generally, a result of the brine
motion. Therefore the vertical transport equations for biogeochemical
tracers will be defined only where brine is present. This region, from
the ice-ocean interface to the brine height, defines the domain of the
vertical bio-grid. The resolution of the bio-grid is specified in
**icepack.settings** by setting the variable NBGCLYR. A detailed description of
the bio-grid is given in section :ref:`bio-grid`. The ice
microstructural state, determined in **icepack\_brine.F90**, is computed
from sea ice salinities and temperatures linearly interpolated to the
bio-grid. When :math:`h_b > h_i`, the upper surface brine is assumed to
have the same temperature as the ice surface.

Brine height is transported horizontally as the fraction
:math:`f_{bri} = h_b/h_i`, a volume conserved tracer. Note that unlike the sea ice porosity, brine height
fraction may be greater than 1 when :math:`h_b > h_i`.

Changes to :math:`h_b` occur from ice and snow melt, ice bottom boundary
changes, and from pressure adjustments. The computation of :math:`h_b`
at :math:`t+\Delta
t` is a two step process. First, :math:`h_b` is updated from changes in
ice and snow thickness, ie.

.. math::
   h_b' = h_b(t) + \Delta h_b|_{h_i,h_s} .
   :label: hb_thickness_changes

Second, pressure driven adjustments arising from meltwater flushing and
snow loading are applied to :math:`h'_b`. Brine flow due to pressure
forces are governed by Darcy’s equation 

.. math::
   w = -\frac{\Pi^* \bar{\rho} g}{\mu}\frac{h_p}{h_i}.
   :label: Darcy1

The vertical component of the net permeability tensor :math:`\Pi^*` is
computed as

.. math::
   \Pi^* = \left(\frac{1}{h}\sum_{i=1}^N{\frac{\Delta
         z_i}{\Pi_i}}\right)^{-1}
   :label: netPi1

where the sea ice is composed of :math:`N` vertical layers with
:math:`i`\ th layer thickness :math:`\Delta z_i` and permeability
:math:`\Pi_i`. The average sea ice density is :math:`\bar{\rho}`
specified in **icepack\_zbgc\_shared.F90**. The hydraulic head is
:math:`h_p = h_b - h_{sl}` where :math:`h_{sl}` is the sea level given
by

.. math::
   h_{sl} = \frac{\bar{\rho}}{\rho_w}h_i + \frac{\rho_s}{\rho_w}h_s .
   :label: hsl

Assuming constant :math:`h_i` and :math:`h_s` during Darcy flow, the
rate of change of :math:`h_b` is

.. math::
   \frac{\partial h_b}{\partial t} = -w h_p
   :label: h_p

where :math:`w_o = \Pi^* \bar{\rho}
g/(h_i\mu\phi_{top})` and :math:`\phi_{top}` is the upper surface
porosity. When the Darcy flow is downward into the ice
(:math:`w_o < 0`), then :math:`\phi_{top}` equals the sea ice porosity
in the uppermost layer. However, when the flow is upwards into the snow,
then :math:`\phi_{top}` equals the snow porosity phi\_snow specified in
**icepack\_in**. If a negative number is specified for phi\_snow, then the
default value is used: phi\_snow :math:`=1 - \rho_s/\rho_w`.

Since :math:`h_{sl}` remains relatively unchanged during Darcy flow,
:eq:`h_p` has the approximate solution

.. math::
   \begin{aligned}
   h_b(t+\Delta t) \approx h_{sl}(t+\Delta t) +  [h'_b - h_{sl}(t+\Delta t)]\exp\left\{-w \Delta t\right\}.\end{aligned}
   :label: brine_height

The contribution :math:`\Delta h_b|_{h_i,h_s}` arises from snow and ice
melt and bottom ice changes. Since the ice and brine bottom boundaries
coincide, changes in the ice bottom from growth or melt,
:math:`(\Delta h_i)_{bot}`, equal the bottom brine boundary changes. The
surface contribution from ice and snow melt, however, is opposite in
sign. The ice contribution is as follows. If :math:`h_i > h_b` and the
ice surface is melting, ie. :math:`(\Delta h_i)_{top} <
0`), then meltwater increases the brine height:

.. math::
   \begin{aligned}
   \left(\Delta h_b\right)_{top} = \frac{\rho_i}{\rho_o} \cdot \left\{ \begin{array}{ll}
    -(\Delta h_i)_{top} &  \mbox{if }
    |(\Delta h_i)_{top}| < h_i-h_b  \\
    h_i-h_b & \mbox{otherwise.}   \end{array} \right.  \end{aligned}
    :label: delta-hb

For snow melt (:math:`\Delta h_s < 0`), it is assumed that all snow
meltwater contributes a source of surface brine. The total change from
snow melt and ice thickness changes is

.. math::
   \Delta h_b|_{h_i,h_s} = \left( \Delta
   h_b\right)_{top} -\left(\Delta h_i\right)_{bot} -\frac{\rho_s}{\rho_o}\Delta h_s.
   :label: dzdt_meltwater

The above brine height calculation is used only when :math:`h_i` and
:math:`h_b` exceed a minimum thickness, thinS, specified in
**icepack\_zbgc\_shared**. Otherwise

.. math::
   h_b(t+\Delta t) = h_b(t) + \Delta h_i
   :label: thinbrine1

provided that :math:`|h_{sl}-h_b| \leq 0.001`. This formulation ensures
small Darcy velocities when :math:`h_b` first exceeds thinS.


Both the volume fraction :math:`f_{bri}` and the area-weighted brine
height :math:`h_b` are available for output.

.. math:: 
   {{\sum f_{bri} v_i} \over {\sum v_i}},
   :label: volume-frac

while ``hbri`` is comparable to hi (:math:`h_i`)

.. math:: 
   {{\sum f_{bri} h_i a_i} \over {\sum a_i}},
   :label: volume-frac2

where the sums are taken over thickness categories.

Sea Ice Biogeochemistry
~~~~~~~~~~~~~~~~~~~~~~~

There are two options for modeling biogeochemistry in sea ice: 1) a
skeletal layer or bottom layer model (skl-model) that assumes biology
and biological molecules are restricted to a single layer at the base of
the sea ice; and 2) a vertically resolved model (zbgc) that allows for
biogeochemical processes throughout the ice column. The two models may
be run with the same suite of biogeochemical tracers and use the same
module **algal\_dyn** in **icepack\_algae.F90** to determine the biochemical
reaction terms for the tracers at each vertical grid level. In the case
of the skl-model this is a single layer, while for zbgc there are
NBGCLYR\ :math:`+1` vertical layers. The primary difference between the
two schemes is in the vertical transport assumptions for each
biogeochemical tracer. This includes the parameterizations of fluxes
between ocean and ice.

In order to run with the skl-model, the code must be built with the
following options in **icepack.settings**:

::

    setenv TRBGCS 1   # set to 1 for skeletal layer tracers
    setenv TRBGCZ 0   # set to 1 for zbgc tracers

For zbgc with 8 vertical layers:

::

    setenv TRBRI  1   # set to 1 for brine height tracer
    setenv TRBGCS 0   # set to 1 for skeletal layer tracers
    setenv TRBGCZ 1   # set to 1 for zbgc tracers
    setenv NBGCLYR 7  # number of zbgc layers 

There are also environmental variables in **icepack.settings** that, in part,
specify the complexity of the ecosystem and are used for both zbgc and
the skl-model. These are 1) TRALG, the number of algal species; 2)
TRDOC, the number of dissolved organic carbon groups, 3) TRDIC, the
number of dissolved inorganic carbon groups (this is currently not yet
implemented and should be set to 0); 4) TRDON, the number of dissolved
organic nitrogen groups, 5) TRFEP , the number of particulate iron
groups; and 6) TRFED, the number of dissolved iron groups. The current
version of **algal\_dyn** biochemistry has parameters for up to 3 algal
species (diatoms, small phytoplankton and *Phaeocystis* sp,
respectively), 2 DOC tracers (polysaccharids and lipids, respectively),
0 DIC tracers, 1 DON tracer (proteins/amino acids), 1 particulate iron
tracer and 1 dissolved iron tracer. Note, for tracers with multiple
species/groups, the order is important. For example, specifying
TRALG = 1 will compute reaction terms using parameters
specific to ice diatoms.  However, many of these parameters can be modified in **icepack\_in**. 

The complexity of the algal ecosystem must be specified in both
**icepack.settings** during the build and in the namelist, **icepack\_in**. The
procedure is equivalent for both the skl-model and zbgc. The namelist
specification is described in detail in section :ref:`zbgc`

Biogeochemical upper ocean concentrations are initialized in the
subroutine **icepack\_init\_ocean\_conc** in **icepack\_zbgc.F90** unless
coupled to the ocean biogeochemistry. Silicate and nitrate may be read
from a file. This option is specified in the namelist by setting the
variables sil\_data\_type and nit\_data\_type to ‘ISPOL’  or 'NICE'. nit\_data\_type also
has an option ‘sss’ which equates the upper ocean nitrate concentration
with sea surface salinity. fe\_data\_type currently only has the
‘default’ option. The location of forcing files is specified in
bgc\_data\_dir and the filename is hardcoded in **icedrv\_forcing** (NJ - needs to be updated).


Skeletal Layer BGC
******************

In the skeletal layer model, biogeochemical processing is modelled as a
single layer of reactive tracers attached to the sea ice bottom.
Optional settings are available via the *zbgc\_nml* namelist in
**icepack\_in**. In particular, skl\_bgc must be true and z\_tracers and
solve\_zbgc must both be false.

History fields are controlled in the *icefields\_bgc\_nml* namelist and
will be discussed in section :ref:`bgc-hist`. As with other CICE
history fields, the suffix \_ai indicates that the field is multiplied
by ice area and is therefore a grid cell average.

Skeletal tracers :math:`T_b` are ice area conserved and follow the
horizontal transport Equation :eq:`itd-transport`. For each
horizontal grid point, local biogeochemical tracer equations are solved
in **icepack\_algae.F90**. There are two types of ice-ocean tracer flux
formulations: 1) ‘Jin2006’ modeled after the growth rate dependent
piston velocity and 2) ‘constant’ modeled after a constant piston
velocity. The formulation is specified in **icepack\_in** by setting
bgc\_flux\_type equal to ‘Jin2006’ or ‘constant’.

In addition to horizontal advection and transport among thickness
categories, biogeochemical tracers (:math:`T_b` where
:math:`b = 1,\ldots, N_b`) satisfy a set of local coupled equations of
the form

.. math::
   \frac{d T_b}{dt} = w_b \frac{\Delta T_b}{\Delta z} +  R_b({T_j : j = 1,\ldots,N_b})
   :label: bgc_Tracer

where :math:`R_b` represents the nonlinear biochemical reaction terms
(described in section :ref:`reactions`) and :math:`\Delta z` is a length
scale representing the molecular sublayer of the ice-ocean interface.
Its value is absorbed in the piston velocity parameters. The piston
velocity :math:`w_b` depends on the particular tracer and the flux
formulation.

For ‘Jin2006’, the piston velocity is a function of ice growth and melt
rates. All tracers (algae included) flux with the same piston velocity
during ice growth, :math:`dh/dt > 0`:

.. math::
   \begin{aligned}
   w_b  & =  & - p_g\left|m_1 + m_2 \frac{dh}{dt} - m_3
     \left(\frac{dh}{dt} \right)^2\right|\end{aligned}
   :label: pwJin_growth

with parameters :math:`m_1`, :math:`m_2`, :math:`m_3` and :math:`p_g`
defined in **skl\_biogeochemistry** in **icepack\_algae.F90**. For ice melt,
:math:`dh/dt < 0`, all tracers with the exception of ice algae flux with

.. math::
   \begin{aligned}
   w_b  & =  & p_m\left|m_2 \frac{dh}{dt} - m_3
       \left(\frac{dh}{dt}  \right)^2\right| \end{aligned}
   :label: pwJin_melt

with :math:`p_m` defined in **skl\_biogeochemistry**. The ‘Jin2006’
formulation also requires that for both expressions,
:math:`|w_b| \leq 0.9
h_{sk}/\Delta t`. The concentration difference at the ice-ocean boundary
for each tracer, :math:`\Delta
T_b`, depends on the sign of :math:`w_b`. For growing ice,
:math:`w_b <0`, :math:`\Delta T_b  = T_b/h_{sk} - T_{io}`, where
:math:`T_{io}` is the ocean concentration of tracer :math:`i`. For
melting ice, :math:`w_b > 0`, :math:`\Delta T_b = T_b/h_{sk}`.

In ‘Jin2006’, the algal tracer (:math:`N_a`) responds to ice melt in the
same manner as the other tracers :eq:`pwJin_melt`. However, this is
not the case for ice growth. Unlike dissolved nutrients, algae are able
to cling to the ice matrix and resist expulsion during desalination. For
this reason, algal tracers do not flux between ice and ocean during ice
growth unless the ice algal brine concentration is less than the ocean
algal concentration (:math:`N_o`). Then the ocean seeds the sea ice
concentration according to

.. math::
   \begin{aligned}
   w_b \frac{\Delta N_a}{\Delta z} = \frac{N_oh_{sk}/\phi_{sk} -
     N_a}{\Delta t}\end{aligned}
   :label: seed2

The ‘constant’ formulation uses a fixed piston velocity (PVc) for
positive ice growth rates for all tracers except :math:`N_a`. As in
‘Jin2006’, congelation ice growth seeds the sea ice algal population
according to :eq:`seed2` when :math:`N_a < N_o
h_{sk}/\phi_{sk}`. For bottom ice melt, all tracers follow the
prescription

.. math::
   \begin{aligned}
    w_b \frac{\Delta T_b}{\Delta z} & = &  \left\{ \begin{array}{ll}
      T_b   |dh_i/dt|/h_{sk} \ \ \ \ \ &   \mbox{if }
    |dh_i/dt|\Delta t/h_{sk} < 1  \\
    T_b/\Delta t & \mbox{otherwise.}   \end{array} \right. \end{aligned} 
    :label: constant_melt

A detailed description of the biogeochemistry reaction terms is given in
section :ref:`reactions`.


.. _zbgc:

Vertical "Z" BGC
****************

In order to solve for the vertically resolved biogeochemistry, several
flags in **icepack\_in** must be true: a) tr\_brine, b) z\_tracers, and c)
solve\_zbgc.

-  a) tr\_brine true, turns on the dynamic brine height tracer,
   :math:`h_b`, which defines the vertical domain of the biogeochemical
   tracers. z-Tracer horizontal transport is conserved on ice
   volume\ :math:`\times`\ brine height fraction.

-  b) z\_tracers true, indicates use of vertically resolved
   biogeochemical and z-aerosol tracers. This flag alone turns on the
   vertical transport scheme but not the biochemistry.

-  c) solve\_zbgc true, turns on the biochemistry for the vertically
   resolved tracers and automatically turns on the algal nitrogen tracer
   flag tr\_bgc\_N. If false, tr\_bgc\_N is set false and any other
   biogeochemical tracers in use are transported as passive tracers.
   This is appropriate for the black carbon and dust aerosols specified
   by tr\_zaero true.

In addition, a halodynamics scheme must also be used. The default
thermo-halodynamics is mushy layer ktherm set to 2. An alternative uses
the Bitz and Lipscomb thermodynamics ktherm set to 1 and solve\_zsal
true (referred to as "zsalinity").

With the above flags true, the default biochemistry is a simple
algal-nitrate system: tr\_bgc\_N and tr\_bgc\_Nit equal true. Options
exist in icepack\_in to use a more complicated ecosystem which includes up
to three algal classes, two DOC groups, one DON pool, limitation by
nitrate, silicate and dissolved iron, sulfur chemistry plus refractory
humic material.

The **icepack\_in** namelist options are described below.

::

    &zbgc_nml
        tr_brine        = .true.     ! turns on the brine height tracer
                                     ! (needs TRBRI 1 in comp_ice)
      , restart_hbrine  = .false.    ! restart the brine height tracer
                                     ! (will be automatically switched on 
                                     ! if restart = .true.)
      , tr_zaero        = .false.    ! turns on black carbon and
                                     ! dust aerosols
      , modal_aero      = .false.    ! turns on a modal aerosol option
                                     ! (not well tested)
      , skl_bgc         = .false.    ! turns on a single bottom layer
                                     ! biogeochemistry.  z_tracers and
                                     ! solve_zbgc must be false 
                                     ! (needs TRBGCS 1 in comp_ice)
      , z_tracers       = .true.     ! turns on vertically resolved transport
                                     ! (needs TRBGCZ 1 in comp_ice)
      , dEdd_algae      = .false.    ! Include radiative impact of algae
                                     ! and aerosols in the delta-Eddington
                                     ! shortwave scheme.  Requires
                                     ! shortwave = 'dEdd'
                                     ! (Should not be used when solve_zbgc
                                     !  of skl_bgc are true*)
      , solve_zbgc      = .true.     ! turns on the biochemistry using z_tracers
                                     ! (specify algal numbers in comp_ice TRALG)
      , bgc_flux_type   = 'Jin2006'  ! ice-ocean flux type for bottom
                                     ! layer tracers only (skl_bgc = .true.)
      , restore_bgc     = .false.    ! restores upper ocean concentration
                                     ! fields to data values (nitrate and
                                     ! silicate)
      , restart_bgc     = .false.    ! restarts biogeochemical tracers
                                     ! (will be automatically switched on
                                     ! if restart = .true.)
      , scale_bgc       = .false.    ! Initializes biogeochemical profiles
                                     ! to scale with prognosed salinity profile
      , solve_zsal      = .false.    ! prognostic salinity tracer used with 
                                     ! ktherm = 1 (zsalinity)
                                     ! (needs TRZS 1 in comp_ice)
      , restart_zsal    = .false.    ! restarts zsalinity
      , bgc_data_dir    = '/nitrate_and_silicate/forcing_directory/'                               
      , sil_data_type   = 'default'  ! fixed, spatially homogenous
                                     ! value. 'clim' data file 
                                     ! (see ice_forcing_bgc.F90)
      , nit_data_type   = 'default'  ! fixed, spatially homogenous
                                     ! value. 'clim' data file 
                                     ! (see ice_forcing_bgc.F90)
      , fe_data_type    = 'default'  ! fixed, spatially homogenous
      , tr_bgc_Nit      = .true.     ! nitrate tracer
      , tr_bgc_C        = .true.     ! Dissolved organic carbon tracers
                                     ! (numbers specified in comp_ice as
                                     ! TRDOC) and dissolved inorganic
                                     ! carbon tracers (not yet implemented, 
                                     ! TRDIC 0 in comp_ice)
      , tr_bgc_chl      = .false.    ! dummy variable for now.  Chl is
                                     ! simply a fixed ratio of algal Nitrogen
      , tr_bgc_Am       = .true.     ! Ammonium   
      , tr_bgc_Sil      = .true.     ! Silicate
      , tr_bgc_DMS      = .true.     ! Three tracers: DMS dimethyl sulfide, DMSPp
                                     ! (assumed to be a fixed ratio of
                                     ! sulfur to algal Nitrogen) and 
                                     ! DMSPd
      , tr_bgc_PON      = .false.    ! passive purely mobile ice tracer with
                                     ! ocean concentration equivalent to nitrate
      , tr_bgc_hum      = .true.     ! refractory DOC or DON (units depend
                                     ! on the ocean source)
      , tr_bgc_DON      = .true.     ! dissolved organic nitrogen (proteins)
      , tr_bgc_Fe       = .true.     ! Dissolved iron (number in comp_ice TRFED)
                                     ! particulate iron (number in comp_ice TRFEP)
      , grid_o          = 0.006      ! ice-ocean surface layer thickness
                                     ! (bgc transport scheme)
      , grid_o_t        = 0.006      ! ice-atm surface layer thickeness
                                     ! (bgc transport scheme)
      , l_sk            = 0.024      ! length scale in gravity drainage
                                     !  parameterization
                                     ! (bgc transport scheme)
      , grid_oS         = 0.0        ! ice-ocean surface layer thickness
                                     ! (zsalinity transport scheme)
      , l_skS           = 0.028      ! ice-atm surface layer thickeness
                                     ! (zsalinity transport scheme)
      , phi_snow        = -0.3       ! snow porosity at the ice-snow interface
                                     ! if < 0 then phi_snow is computed
                                     ! from snow density
      , initbio_frac    = 0.8        ! For each bgc tracer, specifies the 
                                     ! fraction of the ocean
                                     ! concentration that is retained in
                                     ! the ice during initial new ice formation.
      , frazil_scav     = 0.8        ! For each bgc tracer, specifies the
                                     ! fraction or multiple of the ocean
                                     ! concentration that is retained in
                                     ! the ice from frazil formation. 
                                     !----------------------------------------
                                     !  Notation used below: 
                                     !  _diatoms  == diatoms
                                     !  _sp       == small phytoplankton
                                     !  _phaeo    == phaeocystis 
                                     !  _s        == saccharids 
                                     !       (unless otherwise indicated)
                                     !  _l        == lipdids 
                                     !       (unless otherwise indicated)
                                     !---------------------------------------- 
      , ratio_Si2N_diatoms = 1.8_dbl_kind    ! algal Si to N (mol/mol)                        
      , ratio_Si2N_sp      = c0              
      , ratio_Si2N_phaeo   = c0              
      , ratio_S2N_diatoms  = 0.03_dbl_kind   ! algal S  to N (mol/mol) 
      , ratio_S2N_sp       = 0.03_dbl_kind   
      , ratio_S2N_phaeo    = 0.03_dbl_kind   
      , ratio_Fe2C_diatoms = 0.0033_dbl_kind ! algal Fe to C  (umol/mol) 
      , ratio_Fe2C_sp      = 0.0033_dbl_kind 
      , ratio_Fe2C_phaeo   = p1              
      , ratio_Fe2N_diatoms = 0.023_dbl_kind  ! algal Fe to N  (umol/mol) 
      , ratio_Fe2N_sp      = 0.023_dbl_kind  
      , ratio_Fe2N_phaeo   = 0.7_dbl_kind    
      , ratio_Fe2DON       = 0.023_dbl_kind  ! Fe to N of DON (nmol/umol)
      , ratio_Fe2DOC_s     = p1              ! Fe to C of DOC (nmol/umol)
      , ratio_Fe2DOC_l     = 0.033_dbl_kind  ! Fe to C of DOC (nmol/umol) 
      , fr_resp            = 0.05_dbl_kind   ! frac of algal growth lost 
                                             ! due to respiration      
      , tau_min            = 5200.0_dbl_kind ! rapid mobile to stationary 
                                             ! exchanges (s)
      , tau_max            = 1.73e5_dbl_kind ! long time mobile to
                                             ! stationary exchanges (s)
      , algal_vel          = 1.11e-8_dbl_kind! 0.5 cm/d(m/s)
      , R_dFe2dust         = 0.035_dbl_kind  ! g/g (3.5% content)
      , dustFe_sol         = 0.005_dbl_kind  ! solubility fraction
      , chlabs_diatoms     = 0.03_dbl_kind   ! chl absorption (1/m/(mg/m^3)) 
      , chlabs_sp          = 0.01_dbl_kind   
      , chlabs_phaeo       = 0.05_dbl_kind   
      , alpha2max_low_diatoms = 0.8_dbl_kind ! light limitation (1/(W/m^2))   
      , alpha2max_low_sp      = 0.67_dbl_kind
      , alpha2max_low_phaeo   = 0.67_dbl_kind
      , beta2max_diatoms   = 0.018_dbl_kind  ! light inhibition (1/(W/m^2))   
      , beta2max_sp        = 0.0025_dbl_kind 
      , beta2max_phaeo     = 0.01_dbl_kind   
      , mu_max_diatoms     = 1.2_dbl_kind    ! maximum growth rate (1/day) 
      , mu_max_sp          = 0.851_dbl_kind  
      , mu_max_phaeo       = 0.851_dbl_kind  
      , grow_Tdep_diatoms  = 0.06_dbl_kind ! Temperature dependence of 
                                           ! growth (1/C)
      , grow_Tdep_sp       = 0.06_dbl_kind 
      , grow_Tdep_phaeo    = 0.06_dbl_kind 
      , fr_graze_diatoms   = 0.01_dbl_kind ! Fraction grazed 
      , fr_graze_sp        = p1            
      , fr_graze_phaeo     = p1            
      , mort_pre_diatoms   = 0.007_dbl_kind! Mortality (1/day) 
      , mort_pre_sp        = 0.007_dbl_kind
      , mort_pre_phaeo     = 0.007_dbl_kind
      , mort_Tdep_diatoms  = 0.03_dbl_kind ! T dependence of mortality (1/C) 
      , mort_Tdep_sp       = 0.03_dbl_kind 
      , mort_Tdep_phaeo    = 0.03_dbl_kind 
      , k_exude_diatoms    = c0            ! algal exudation (1/d) 
      , k_exude_sp         = c0            
      , k_exude_phaeo      = c0            
      , K_Nit_diatoms      = c1            ! nitrate half saturation 
                                           ! (mmol/m^3) 
      , K_Nit_sp           = c1            
      , K_Nit_phaeo        = c1            
      , K_Am_diatoms       = 0.3_dbl_kind  ! ammonium half saturation 
                                           ! (mmol/m^3) 
      , K_Am_sp            = 0.3_dbl_kind  
      , K_Am_phaeo         = 0.3_dbl_kind  
      , K_Sil_diatoms      = 4.0_dbl_kind  ! silicate half saturation 
                                           ! (mmol/m^3) 
      , K_Sil_sp           = c0            
      , K_Sil_phaeo        = c0            
      , K_Fe_diatoms       = c1            ! iron half saturation (nM) 
      , K_Fe_sp            = 0.2_dbl_kind  
      , K_Fe_phaeo         = p1            
      , f_don_protein      = 0.6_dbl_kind  ! fraction of spilled grazing 
                                           ! to proteins           
      , kn_bac_protein     = 0.03_dbl_kind ! Bacterial degredation of DON (1/d)                
      , f_don_Am_protein   = 0.25_dbl_kind ! fraction of remineralized 
                                           ! DON to ammonium         
      , f_doc_s            = 0.4_dbl_kind  ! fraction of mortality to DOC 
      , f_doc_l            = 0.4_dbl_kind  ! 
      , f_exude_s          = c1            ! fraction of exudation to DOC 
      , f_exude_l          = c1            ! 
      , k_bac_s            = 0.03_dbl_kind ! Bacterial degredation of DOC (1/d) 
      , k_bac_l            = 0.03_dbl_kind ! 
      , T_max              = c0            ! maximum temperature (C)
      , fsal               = c1            ! Salinity limitation (ppt)
      , op_dep_min         = p1            ! Light attenuates for optical 
                                           ! depths exceeding min
      , fr_graze_s         = p5            ! fraction of grazing spilled 
                                           ! or slopped
      , fr_graze_e         = p5            ! fraction of assimilation excreted 
      , fr_mort2min        = p5            ! fractionation of mortality to Am
      , fr_dFe             = 0.3_dbl_kind  ! fraction of remineralized nitrogen
      ,                                    ! (in units of algal iron)
      , k_nitrif           = c0            ! nitrification rate (1/day)           
      , t_iron_conv        = 3065.0_dbl_kind ! desorption loss pFe to dFe (day)
      , max_loss           = 0.9_dbl_kind  ! restrict uptake to % of remaining value 
      , max_dfe_doc1       = 0.2_dbl_kind  ! max ratio of dFe to 
                                           ! saccharides in the ice 
                                           !(nM Fe/muM C)    
      , fr_resp_s          = 0.75_dbl_kind ! DMSPd fraction of respiration 
                                           ! loss as DMSPd
      , y_sk_DMS           = p5            ! fraction conversion given high yield
      , t_sk_conv          = 3.0_dbl_kind  ! Stefels conversion time (d)
      , t_sk_ox            = 10.0_dbl_kind ! DMS oxidation time (d)
      , algaltype_diatoms  = c0            ! ------------------
      , algaltype_sp       = p5            !
      , algaltype_phaeo    = p5            !
      , nitratetype        = -c1           ! mobility type between
      , ammoniumtype       = c1            ! stationary <-->  mobile
      , silicatetype       = -c1           !
      , dmspptype          = p5            !
      , dmspdtype          = -c1           !
      , humtype            = c1            !
      , doctype_s          = p5            ! 
      , doctype_l          = p5            ! 
      , dontype_protein    = p5            !
      , fedtype_1          = p5            !
      , feptype_1          = p5            !
      , zaerotype_bc1      = c1            !
      , zaerotype_bc2      = c1            !
      , zaerotype_dust1    = c1            !
      , zaerotype_dust2    = c1            !
      , zaerotype_dust3    = c1            !
      , zaerotype_dust4    = c1            !--------------------
      , ratio_C2N_diatoms  = 7.0_dbl_kind  ! algal C to N ratio (mol/mol)
      , ratio_C2N_sp       = 7.0_dbl_kind  
      , ratio_C2N_phaeo    = 7.0_dbl_kind  
      , ratio_chl2N_diatoms= 2.1_dbl_kind  ! algal chlorophyll to N ratio (mg/mmol)
      , ratio_chl2N_sp     = 1.1_dbl_kind  
      , ratio_chl2N_phaeo  = 0.84_dbl_kind 
      , F_abs_chl_diatoms  = 2.0_dbl_kind  ! scales absorbed radiation for dEdd
      , F_abs_chl_sp       = 4.0_dbl_kind  
      , F_abs_chl_phaeo    = 5.0           
      , ratio_C2N_proteins = 7.0_dbl_kind  ! ratio of C to N in proteins (mol/mol)        
    /

Vertically resolved z-tracers are brine volume conserved and thus depend
on both the ice volume and the brine height fraction tracer
(:math:`v_{in}f_b`). These tracers follow the conservation equations for
multiply dependent tracers (see, for example Equation :eq:`transport-apnd-lvl` where :math:`a_{pnd}` is a tracer on :math:`a_{lvl}a_{i}`)  

The
following sections describe the vertical biological grid, the vertical
transport equation for mobile tracers, the partitioning of tracers into
mobile and stationary fractions and the biochemical reaction equations.

.. _bio-grid:

Bio grid
````````

The bio grid is a vertical grid used for solving the brine height
variable :math:`h_b` and descretizing the vertical transport equations
of biogeochemical tracers. The bio grid is a non-dimensional vertical
grid which takes the value zero at :math:`h_b` and one at the ice-ocean
interface. The number of grid levels is specified during compilation in
**icepack.settings** by setting the variable NBGCLYR equal to an integer
(:math:`n_b`) .

Ice tracers and microstructural properties defined on the bio grid are
referenced in two ways: as 1) :math:`n_b+2` bgrid points and 2)
:math:`n_b+1` igrid points. For both bgrid and igrid, the first and last
points reference :math:`h_b` and the ice-ocean interface and so take the
values :math:`0` and :math:`1`, respectively. For bgrid, the interior
points :math:`[2, n_b+1]` are spaced at :math:`1/n_b` intervals
beginning with bgrid(2) = :math:`1/(2n_b)` . 
The igrid interior points :math:`[2, n_b]` are also
equidistant with the same spacing, but physically coincide with points
midway between those of the bgrid.

.. _trans-bio-grid:

Transport along the interface bio grid
``````````````````````````````````````

Purely mobile tracers are tracers which move with the brine and thus, in
the absence of biochemical reactions, evolve like salinity. For vertical
tracer transport of purely mobile tracers, the flux conserved quantity
is the bulk tracer concentration multiplied by the ice thickness, i.e.
:math:`C = h\phi
[c]`, where :math:`h` is the ice thickness, :math:`\phi` is the
porosity, and :math:`[c]` is the tracer concentration in the brine.
:math:`\phi`, :math:`[c]` and :math:`C` are defined on the interface bio
grid (igrid):

.. math::
   \mbox{igrid}(k) = \Delta (k-1) \ \ \ \mbox{for }k = 1:n_b+1

and :math:`\Delta = 1/n_b`

The biogeochemical module solves the following equation:

.. math::
   \begin{aligned}
   \frac{\partial C}{\partial t} & =& \frac{\partial }{\partial x}\left\{
   \left( \frac{v}{h} + \frac{w_f}{h\phi} -
     \frac{\tilde{D}}{h^2\phi^2}\frac{\partial \phi}{\partial x} \right) C
   + \frac{\tilde{D}}{h^2\phi}\frac{\partial C}{\partial x} 
   \right\} + h\phi R([c])\end{aligned}
   :label: mobile-transport

where :math:`D_{in} = \tilde{D}/h^2 =  (D + \phi D_m)/h^2` and
:math:`R([c])` is the nonlinear biogeochemical interaction term (see
:cite:`JHE11`).

The solution to :eq:`mobile-transport` is flux-corrected and
positive definite. This is accomplished using a finite element Gelerkin
discretization. Details are in :ref:`tracer-numerics` .

Splitting tracers: zbgc\_type
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

In addition to purely mobile tracers, some tracers may also adsorb or
otherwise adhere to the ice crystals. These tracers exist in both the
mobile and stationary phases. In this case, their total brine
concentration is a sum :math:`c_m + c_s` where :math:`c_m` is the moble
fraction transported by equation :eq:`mobile-transport` and :math:`c_s`
is fixed vertically in the ice matrix. The algae are an exception,
however. We assume that algae in the stationary phase resist brine
motion, but rather than being fixed vertically, these tracers maintain
their relative position in the ice. Algae that adhere to the ice
interior (bottom, surface), remain in the ice interior (bottom, surface)
until release to the mobile phase.

In order to model the transfer between these fractions, we assume that
tracers adhere (are retained) to the crystals with a time-constant of
:math:`\tau_{ret}`, and release with a time constant :math:`\tau_{rel}`,
i.e.

.. math::
   \begin{aligned}
   \frac{\partial c_m}{\partial t} & = & -\frac{c_m}{\tau_{ret}} + \frac{c_s}{\tau_{rel}} \\
   \frac{\partial c_s}{\partial t} & = &\frac{c_m}{\tau_{ret}} - \frac{c_s}{\tau_{rel}}\end{aligned}

We use the exponential form of these equations:

.. math::
   \begin{aligned}
   c_m^{t+dt} & = &
   c_m^t\exp\left(\left\{-\frac{dt}{\tau_{ret}}\right)\right\} +
   c^t_s\left(1- \exp\left[-\left\{\frac{dt}{\tau_{rel}}\right\}\right]\right)\end{aligned}

.. math::
   \begin{aligned}
   c_s^{t+dt} & = & c_s^t\exp\left(\left\{-\frac{dt}{\tau_{rel}}\right)\right\} +
   c_m^t\left(1-\exp\left[-\left\{\frac{dt}{\tau_{ret}}\right\}\right]\right) \end{aligned}

The time constants are functions of the ice growth and melt rates
(:math:`dh/dt`). All tracers except algal nitrogen diatoms follow the
simple case: when :math:`dh/dt \geq 0`, then
:math:`\tau_{rel} \rightarrow \infty` and :math:`\tau_{ret}` is finite.
For :math:`dh/dt < 0`, then :math:`\tau_{ret} \rightarrow \infty` and
:math:`\tau_{rel}` is finite. In other words, ice growth promotes
transitions to the stationary phase and ice melt enables transitions to
the mobile phase.

The exception is the diatom pool. We assume that diatoms, the first
algal nitrogen group, can actively maintain their relative position
within the ice, i.e. bottom (interior, upper) algae remain in the bottom
(interior, upper) ice, unless melt rates exceed a threshold. The
namelist parameter algal\_vel sets this threshold.

.. _mobile-and-stationary:

Mobile and Stationary Phases in code
************************************

The variable bgc\_tracer\_type determines the mobile to stationary
transition timescales for each z-tracer. It is multi-dimensional with a
value for each z-tracer. For bgc\_tracer\_type(k) equal to -1, the kth
tracer remains solely in the mobile phase. For bgc\_tracer\_type(k)
equal to 1, the tracer has maximal rates in the retention phase and
minimal in the release. For bgc\_tracer\_type(k) equal to 0, the tracer
has maximal rates in the release phase and minimal in the retention.
Finally for bgc\_tracer\_type(k) equal to 0.5, minimum timescales are
used for both transitions. :ref:`tab-phases` summarizes the
transition types. The tracer types are: algaltype\_diatoms,
algaltype\_sp (small plankton), algaltype\_phaeo (*phaeocystis*),
nitratetype, ammoniumtype, silicatetype, dmspptype, dmspdtype, humtype,
doctype\_s (saccharids), doctype\_l (lipids), dontype\_protein,
fedtype\_1, feptype\_1, zaerotype\_bc1 (black carbon class 1),
zaerotype\_bc2 (black carbon class 2), and four dust classes,
zaerotype\_dustj, where J takes values 1 to 4. These may be modified to
increase or decrease retention. Another option is to alter the minimum
tau_min and maximum tau_max timescales which would impact all the
z-tracers.

:ref:`tab-phases`: *Types of Mobile and Stationary Transitions*

.. _tab-phases:

.. table:: Table 3

   +-----------------+--------------------+--------------------+------------------------------+
   | bgc_tracer_type | :math:`\tau_{ret}` | :math:`\tau_{rel}` |        Description           |
   +=================+====================+====================+==============================+
   |     -1.0        | :math:`\infty`     |         0          | entirely in the mobile phase |
   +-----------------+--------------------+--------------------+------------------------------+
   |      0.0        |       min          |        max         |     retention dominated      |
   +-----------------+--------------------+--------------------+------------------------------+
   |      1.0        |       max          |        min         |      release dominated       |
   +-----------------+--------------------+--------------------+------------------------------+
   |      0.5        |       min          |        min         |  equal but rapid exchange    |
   +-----------------+--------------------+--------------------+------------------------------+
   |      2.0        |       max          |        max         |  equal but slow exchange     |
   +-----------------+--------------------+--------------------+------------------------------+

The fraction of a given tracer in the mobile phase is independent of ice
depth and stored in the tracer variable zbgc\_frac. The horizontal
transport of this tracer is conserved on brine volume and so is
dependent on two tracers: brine height fraction (:math:`f_b`) and ice
volume (:math:`v_{in}`). The conservation equations are given by Eq. 18
in the CICE.v5 documentation with :math:`a_{pnd}a_{i}` replaced by
:math:`f_bv_{in}`.

The tracer, zbgc\_frac, is initialized to 1 during new ice formation,
because all z-tracers are initially in the purely mobile phase.
Similarly, as the ice melts, z-tracers return to the mobile phase. Very
large release timescales will prevent this transition and could result
in an unphysically large accumulation during the melt season.

.. _reactions:

Reaction Terms
~~~~~~~~~~~~~~

The biogeochemical reaction terms for each biogeochemical tracer (see
table :ref:`tab-bio-tracer` for tracer definitions) are defined in
**icepack\_algae.F90** in the subroutine algal\_dyn. The same set of
equations is used for the bottom layer model (when sk\_bgc is true) and
the multi-layer biogeochemical model (when z\_tracers and solve\_zbgc
are true).

:ref:`tab-bio-tracer`: *Biogeochemical Tracers*

.. _tab-bio-tracer:

.. csv-table:: Table 4
   :header: "Text Variable", "Variable in code", "flag", "Description", "units"
   :widths: 7, 15, 15, 15, 15

   "N (1)", "Nin(1)", "`tr_bgc_N`", "diatom", ":math:`mmol` :math:`N/m^3`"
   "N (2)", "Nin(2)", "`tr_bgc_N`", "small phytoplankton", ":math:`mmol` :math:`N/m^3`"
   "N (3)", "Nin(3)", "`tr_bgc_N`", "*Phaeocystis sp*", ":math:`mmol` :math:`N/m^3`"
   "DOC (1)", "DOCin(1)", "`tr_bgc_DOC`", "polysaccharids", ":math:`mmol` :math:`C/m^3`"
   "DOC (2)", "DOCin(2)", "`tr_bgc_DOC`", "lipids", ":math:`mmol` :math:`C/m^3`"
   "DON", "DONin(1)", "`tr_bgc_DON`", "proteins", ":math:`mmol` :math:`C/m^3`"
   "fed", "Fedin(1)", "`tr_bgc_Fe`", "dissolved iron", ":math:`\mu` :math:`Fe/m^3`"
   "fep", "Fepin(1)", "`tr_bgc_Fe`", "particulate iron", ":math:`\mu` :math:`Fe/m^3`"
   ":math:`{\mbox{NO$_3$}}`", "Nitin", "`tr_bgc_Nit`", ":math:`{\mbox{NO$_3$}}`", ":math:`mmol` :math:`N/m^3`"
   ":math:`{\mbox{NH$_4$}}`", "Amin", "`tr_bgc_Am`", ":math:`{\mbox{NH$_4$}}`", ":math:`mmol` :math:`N/m^3`"
   ":math:`{\mbox{SiO$_3$}}`", "Silin", "`tr_bgc_Sil`", ":math:`{\mbox{SiO$_2$}}`", ":math:`mmol` :math:`Si/m^3`"
   "DMSPp", "DMSPpin", "`tr_bgc_DMS`", "particulate DMSP", ":math:`mmol` :math:`S/m^3`"
   "DMSPd", "DMSPdin", "`tr_bgc_DMS`", "dissolved DMSP", ":math:`mmol` :math:`S/m^3`"
   "DMS", "DMSin", "`tr_bgc_DMS`", "DMS", ":math:`mmol` :math:`S/m^3`"
   "PON", "PON :math:`^a`", "`tr_bgc_PON`", "passive mobile tracer", ":math:`mmol` :math:`N/m^3`"
   "hum", "hum :math:`^{ab}`", "`tr_bgc_hum`", "passive sticky tracer", ":math:`mmol` :math:`/m^3`"
   "BC (1)", "zaero(1) :math:`^a`", "`tr_zaero`", "black carbon species 1", ":math:`kg` :math:`/m^3`"
   "BC (2)", "zaero(2) :math:`^a`", "`tr_zaero`", "black carbon species 2", ":math:`kg` :math:`/m^3`"
   "dust (1)", "zaero(3) :math:`^a`", "`tr_zaero`", "dust species 1", ":math:`kg` :math:`/m^3`"
   "dust (2)", "zaero(4) :math:`^a`", "`tr_zaero`", "dust species 2", ":math:`kg` :math:`/m^3`"
   "dust (3)", "zaero(5) :math:`^a`", "`tr_zaero`", "dust species 3", ":math:`kg` :math:`/m^3`"
   "dust (4)", "zaero(6) :math:`^a`", "`tr_zaero`", "dust species 4", ":math:`kg` :math:`/m^3`"

:math:`^a` not modified in ``algal_dyn``

:math:`^b` may be in C or N units depending on the ocean concentration

The Reaction Equations
**********************

The biochemical reaction term for each algal species has the form:

.. math::
   \Delta {\mbox{N}}/dt = R_{{\mbox{N}}} = \mu (1- f_{graze} - f_{res}) - M_{ort}

where :math:`\mu` is the algal growth rate, :math:`M_{ort}` is a
mortality loss, :math:`f_{graze}` is the fraction of algal growth that
is lost to predatory grazing, and :math:`f_{res}` is the fraction of
algal growth lost to respiration. Algal mortality is temperture
dependent and limited by a maximum loss rate fraction (:math:`l_{max}`):

.. math::
   M_{ort} = \min( l_{max}[{\mbox{N}}], m_{pre} \exp\{m_{T}(T-T_{max})\}[{\mbox{N}}])

Note, :math:`[\cdots]` denotes brine concentration.

Nitrate and ammonium reaction terms are given by

.. math::

   \begin{aligned}
   \Delta{\mbox{NO$_3$}}/dt & = & R_{{\mbox{NO$_3$}}} =  [{\mbox{NH$_4$}}] k_{nitr}- U^{tot}_{{\mbox{NO$_3$}}} \nonumber \\
   \Delta{\mbox{NH$_4$}}/dt & = & R_{{\mbox{NH$_4$}}} = -[{\mbox{NH$_4$}}] k_{nitr} -U^{tot}_{{\mbox{NH$_4$}}} +
   (f_{ng}f_{graze}(1-f_{gs})+f_{res})\mu^{tot} \nonumber \\
    &  +  & f_{nm} M_{ort}
   \nonumber \\
                        & = &  -[{\mbox{NH$_4$}}]k_{nitr} -U^{tot}_{{\mbox{NH$_4$}}} + N_{remin}\end{aligned}

where the uptake :math:`U^{tot}` and algal growth :math:`\mu^{tot}` are
accumulated totals for all algal species. :math:`k_{nitr}` is the
nitrification rate and :math:`f_{ng}` and :math:`f_{nm}` are the
fractions of grazing and algal mortality that are remineralized to
ammonium and :math:`f_{gs}` is the fraction of grazing spilled or lost.
Algal growth and nutrient uptake terms are described in more detail in
:ref:`growth-uptake`.

Dissolved organic nitrogen satisfies the equation

.. math::

   \begin{aligned}
   \Delta {\mbox{DON}}/dt & = & R_{{\mbox{DON}}} = f_{dg}f_{gs}f_{graze}\mu^{tot} - [{\mbox{DON}}]k_{nb}\end{aligned}

With a loss from bacterial degration (rate :math:`k_{nb}`) and a gain
from spilled grazing that does not enter the :math:`{\mbox{NH$_4$}}`
pool.

A term Z\ :math:`_{oo}` closes the nitrogen cycle by summing all the
excess nitrogen removed as zooplankton/bacteria in a timestep. This term
is not a true tracer, i.e. not advected horizontally with the ice
motion, but provides a diagnostic comparison of the amount of :math:`N`
removed biogeochemically from the ice
:math:`{\mbox{N}}`-:math:`{\mbox{NO$_3$}}`-:math:`{\mbox{NH$_4$}}`-:math:`{\mbox{DON}}`
cycle at each timestep.

.. math::

   \begin{aligned}
   \mbox{Z}_{oo} & = & [(1-f_{ng}(1-f_{gs}) - f_{dg}f_{gs}]f_{graze}\mu^{tot}dt + (1-f_{nm})M_{ort}dt  +
   [{\mbox{DON}}]k_{nb}dt \nonumber\end{aligned}

Dissolved organic carbon may be divided into polysaccharids and lipids.
Parameters are two dimensional (indicated by superscript :math:`i`) with
index 1 corresponding to polysaccharids and index 2 appropriate for
lipids. The :math:`{\mbox{DOC}}^i` equation is:

.. math::

   \begin{aligned}
   \Delta {\mbox{DOC}}^i/dt & = & R_{{\mbox{DOC}}} = f^i_{cg}f_{ng}\mu^{tot} + R^i_{c:n}M_{ort}-[{\mbox{DOC}}]k^i_{cb}\end{aligned}

Silicate has no biochemical source terms within the ice and is lost only
through algal uptake:

.. math::

   \begin{aligned}
   \Delta {\mbox{SiO$_3$}}/dt & = & R_{{\mbox{SiO$_3$}}} = -U_{{\mbox{SiO$_3$}}}^{tot}\end{aligned}

Dissolved iron has algal uptake and remineralization pathways. In
addition, :math:`{\mbox{fed}}` may be converted to or released from the
particulate iron pool depending on the dissolve iron
(:math:`{\mbox{fed}}`) to polysaccharid (:math:`{\mbox{DOC}}(1)`)
concentration ratio. If this ratio exceeds a maximum value
:math:`r^{max}_{fed:doc}` then the change in concentration for dissolved
and particulate iron is

.. math::

   \begin{aligned}
   \Delta_{fe}{\mbox{fed}}/dt & = & -[{\mbox{fed}}]/\tau_{fe} \nonumber \\
   \Delta_{fe}{\mbox{fep}}/dt & = & [{\mbox{fed}}]/\tau_{fe}\end{aligned}

For values less than :math:`r^{max}_{fed:doc}`

.. math::

   \begin{aligned}
   \Delta_{fe}{\mbox{fed}}/dt & = & [{\mbox{fep}}]/\tau_{fe} \nonumber \\
   \Delta_{fe}{\mbox{fep}}/dt & = & -[{\mbox{fep}}]/\tau_{fe}\end{aligned}

Very long timescales :math:`\tau_{fe}` will remove this source/sink
term. The default value is currently set at 3065 days to turn off this
dependency. 61-65 days is a more realistic option (Parekh et al., 2004).

The full equation for :math:`{\mbox{fed}}` including uptake and
remineralization is

.. math::

   \begin{aligned}
   \Delta {\mbox{fed}}/dt & = & R_{{\mbox{fed}}} = -U^{tot}_{{\mbox{fed}}} + f_{fa}R_{fe:n}N_{remin}
   + \Delta_{fe}{\mbox{fed}}/dt\end{aligned}

Particulate iron also includes a source term from algal mortality and
grazing that is not immediately bioavailable. The full equation for
:math:`{\mbox{fep}}` is

.. math::

   \begin{aligned}
   \Delta {\mbox{fep}}/dt & = & R_{{\mbox{fep}}} =  R_{fe:n}[\mbox{Z}_{oo}/dt + (1-f_{fa})]N_{remin}
   + \Delta_{fe}{\mbox{fep}}/dt\end{aligned}

The sulfur cycle includes :math:`{\mbox{DMS}}` and dissolved DMSP
(:math:`{\mbox{DMSPd}}`). Particulate DMSP is assumed to be proportional
to the algal concentration, i.e.
:math:`{\mbox{DMSPp}}= R^i_{s:n}{\mbox{N}}^i` for algal species
:math:`i`. For :math:`{\mbox{DMSP}}` and :math:`{\mbox{DMS}}`,

.. math::

   \begin{aligned}
   \Delta {\mbox{DMSPd}}/dt & = & R_{{\mbox{DMSPd}}} = R_{s:n}[ f_{sr}f_{res}\mu^{tot}
   +f_{nm}M_{ort} ] - [{\mbox{DMSPd}}]/\tau_{dmsp} \nonumber \\
   \Delta {\mbox{DMS}}/dt & = & R_{{\mbox{DMS}}} =  y_{dms}[{\mbox{DMSPd}}]/\tau_{dmsp} - [{\mbox{DMS}}]/\tau_{dms}\end{aligned}

See :ref:`tuning` and Table :ref:`tab-bio-tracers2` for a more
complete list and description of biogeochemical parameters.

.. _growth-uptake:

Algal Growth and Nutrient Uptake
`````````````````````````````````

Nutrient limitation terms are defined, in the simplest ecosystem, for
:math:`{\mbox{NO$_3$}}`. If the appropriate tracer flags are true, then
limitation terms may also be found for :math:`{\mbox{NH$_4$}}`,
:math:`{\mbox{SiO$_3$}}`, and :math:`{\mbox{fed}}`

.. math::
   \begin{aligned}
   {\mbox{NO$_3$}}_{lim} & = & \frac{[{\mbox{NO$_3$}}]}{[{\mbox{NO$_3$}}] + K_{{\mbox{NO$_3$}}}} \nonumber \\
   {\mbox{NH$_4$}}_{lim} & = & \frac{[{\mbox{NH$_4$}}]}{[{\mbox{NH$_4$}}] + K_{{\mbox{NH$_4$}}}}\nonumber \\
   N_{lim} & = &\mbox{min}(1,{\mbox{NO$_3$}}_{lim} + {\mbox{NH$_4$}}_{lim}) \nonumber \\
   {\mbox{SiO$_3$}}_{lim} & = & \frac{[{\mbox{SiO$_3$}}]}{[{\mbox{SiO$_3$}}] + K_{{\mbox{SiO$_3$}}}} \nonumber \\
   {\mbox{fed}}_{lim} & = & \frac{[{\mbox{fed}}]}{[{\mbox{fed}}] + K_{{\mbox{fed}}}} \end{aligned}

Light limitation :math:`L_{lim}` is defined in the following way:
:math:`I
_{sw}(z)` (in :math:`W/m^2`) is the shortwave radiation at the ice level
and the optical depth is proportional to the chlorophyll concentration,
:math:`op_{dep} = chlabs [{\mbox{Chl}a}]` . If ( :math:`op_{dep} > op_{min}`) then

.. math::
   I_{avg} = I_{sw}(1- \exp(-op_{dep}))/op_{dep}

otherwise :math:`I_{avg} = I_{sw}`.

.. math::
   L_{lim} = (1 - \exp(-\alpha\cdot I_{avg}))\exp(-\beta \cdot I_{avg})

The maximal algal growth rate before limitation is

.. math::
   \begin{aligned}
   \mu_o & = & \mu_{max}\exp(\mu_T\Delta T)f_{sal}[{\mbox{N}}] \\ 
   \mu' & = & min(L_{lim},N_{lim},{\mbox{SiO$_3$}}_{lim},{\mbox{fed}}_{lim}) \mu_o\end{aligned}

where :math:`\mu'` is the initial estimate of algal growth rate for a
given algal species and :math:`\Delta T` is the difference between the
local tempurature and the maximum (in this case
T\ :math:`_{max} = 0^o`\ C).

The initial estimate of the uptake rate for silicate and iron is

.. math::
   \begin{aligned}
   \tilde{U}_{{\mbox{SiO$_3$}}} & = & R_{si:n}\mu' \\
   \tilde{U}_{{\mbox{fed}}} & = & R_{fe:n}\mu' \end{aligned}

For nitrogen uptake, we assume that ammonium is preferentially acquired
by algae. To determine the nitrogen uptake needed for each algal growth
rate of :math:`\mu`, first determine the "potential" uptake rate of
ammonium:

.. math::
   U'_{{\mbox{NH$_4$}}} = {\mbox{NH$_4$}}_{lim}\mu_o

Then

.. math::
   \begin{aligned}
   \tilde{U}_{{\mbox{NH$_4$}}} & = & \min(\mu', U'_{{\mbox{NH$_4$}}}) \\
   \tilde{U}_{{\mbox{NO$_3$}}} & = & \mu' - \tilde{U}_{{\mbox{NH$_4$}}}\end{aligned}

We require that each rate not exceed a maximum loss rate
:math:`l_{max}/dt`.This is particularly important when multiple species
are present. In this case, the accumulated uptake rate for each nutrient
is found and the fraction (:math:`fU^i`) of uptake due to algal species
:math:`i` is saved. Then the total uptake rate is compared with the
maximum loss condition. For example, the net uptake of nitrate when
there are three algal species is

.. math::
   \tilde{U}^{tot}_{{\mbox{NO$_3$}}} = \sum^{3}_{i=1}\tilde{U}^i_{{\mbox{NO$_3$}}}\ \ \ .

Then the uptake fraction for species :math:`i` and the adjusted total
uptake is

.. math::
   \begin{aligned}
   fU^i_{{\mbox{NO$_3$}}} & = & \frac{\tilde{U}^i_{{\mbox{NO$_3$}}}}{\tilde{U}^{tot}_{{\mbox{NO$_3$}}}} \nonumber \\
   U^{tot}_{{\mbox{NO$_3$}}} & = & \min(\tilde{U}^{tot}_{{\mbox{NO$_3$}}}, l_{max}[{\mbox{NO$_3$}}]/dt)\end{aligned}

Now, for each algal species the nitrate uptake is

.. math::
   U^i_{{\mbox{NO$_3$}}} = fU^i_{{\mbox{NO$_3$}}} U^{tot}_{{\mbox{NO$_3$}}}

Similar expressions are found for all potentially limiting nutrients.
Then the true growth rate for each algal species :math:`i` is

.. math::
   \begin{aligned}
   \mu^i & = & \min(U^i_{{\mbox{SiO$_3$}}}/R_{si:n}, U^i_{{\mbox{NO$_3$}}} + U^i_{{\mbox{NH$_4$}}}, U^i_{{\mbox{fed}}}/R_{fe:n})\end{aligned}

Preferential ammonium uptake is assumed once again and the remaining
nitrogen is taken from the nitrate pool.


.. _tuning:

BGC Tuning Parameters
`````````````````````

Biogeochemical tuning parameters are specified as namelist options in
**icepack\_in**. Table :ref:`tab-bio-tracers2` provides a list of parameters
used in the reaction equations, their representation in the code, a
short description of each and the default values. Please keep in mind
that there has only been minimal tuning of the model.

:ref:`tab-bio-tracers2` :*Biogeochemical Reaction Parameters*

.. _tab-bio-tracers2:

.. csv-table:: Table 5
   :header: "Text Variable", "Variable in code", "Description", "Value", "units"
   :widths: 7, 20, 15, 15, 15

   ":math:`f_{graze}`", "fr\_graze(1:3)", "fraction of growth grazed", "0, 0.1, 0.1", "1"
   ":math:`f_{res}`", "fr\_resp", "fraction of growth respired", "0.05", "1"
   ":math:`l_{max}`", "max\_loss", "maximum tracer loss fraction", "0.9", "1"
   ":math:`m_{pre}`", "mort\_pre(1:3)", "maximum mortality rate", "0.007, 0.007, 0.007", "day\ :math:`^{-1}`"
   ":math:`m_{T}`", "mort\_Tdep(1:3)", "mortality temperature decay", "0.03, 0.03, 0.03", ":math:`^o`\ C\ :math:`^{-1}`"
   ":math:`T_{max}`", "T\_max", "maximum brine temperature", "0", ":math:`^o`\ C"
   ":math:`k_{nitr}`", "k\_nitrif", "nitrification rate", "0", "day\ :math:`^{-1}`"
   ":math:`f_{ng}`", "fr\_graze\_e", "fraction of grazing excreted", "0.5", "1"
   ":math:`f_{gs}`", "fr\_graze\_s", "fraction of grazing spilled", "0.5", "1"
   ":math:`f_{nm}`", "fr\_mort2min", "fraction of mortality to :math:`{\mbox{NH$_4$}}`", "0.5", "1"
   ":math:`f_{dg}`", "f\_don", "frac. spilled grazing to :math:`{\mbox{DON}}`", "0.6", "1"
   ":math:`k_{nb}`", "kn\_bac :math:`^a`", "bacterial degradation of :math:`{\mbox{DON}}`", "0.03", "day\ :math:`^{-1}`"
   ":math:`f_{cg}`", "f\_doc(1:3)", "fraction of mortality to :math:`{\mbox{DOC}}`", "0.4, 0.4, 0.2 ", "1"
   ":math:`R_{c:n}^c`", "R\_C2N(1:3)", "algal carbon to nitrogen ratio", "7.0, 7.0, 7.0", "mol/mol"
   ":math:`k_{cb}`", "k\_bac1:3\ :math:`^a`", "bacterial degradation of DOC", "0.03, 0.03, 0.03", "day\ :math:`^{-1}`"
   ":math:`\tau_{fe}`", "t\_iron\_conv", "conversion time pFe :math:`\leftrightarrow` dFe", "3065.0 ", "day"
   ":math:`r^{max}_{fed:doc}`", "max\_dfe\_doc1", "max ratio of dFe to saccharids", "0.1852", "nM Fe\ :math:`/\mu`\ M C"
   ":math:`f_{fa}`", "fr\_dFe  ", "fraction of remin. N to dFe", "0.3", "1"
   ":math:`R_{fe:n}`", "R\_Fe2N(1:3)", "algal Fe to N ratio", "0.023, 0.023, 0.7", "mmol/mol"
   ":math:`R_{s:n}`", "R\_S2N(1:3)", "algal S to N ratio", "0.03, 0.03, 0.03", "mol/mol"
   ":math:`f_{sr}`", "fr\_resp\_s", "resp. loss as DMSPd", "0.75", "1"
   ":math:`\tau_{dmsp}`", "t\_sk\_conv", "Stefels rate", "3.0", "day"
   ":math:`\tau_{dms}`", "t\_sk\_ox", "DMS oxidation rate", "10.0", "day"
   ":math:`y_{dms}`", "y\_sk\_DMS", "yield for DMS conversion", "0.5", "1"
   ":math:`K_{{\mbox{NO$_3$}}}`", "K\_Nit(1:3)", ":math:`{\mbox{NO$_3$}}` half saturation constant", "1,1,1", "mmol/m\ :math:`^{3}`"
   ":math:`K_{{\mbox{NH$_4$}}}`", "K\_Am(1:3)", ":math:`{\mbox{NH$_4$}}` half saturation constant", "0.3, 0.3, 0.3", "mmol/m\ :math:`^{-3}`"
   ":math:`K_{{\mbox{SiO$_3$}}}`", "K\_Sil(1:3)", "silicate half saturation constant", "4.0, 0, 0", "mmol/m\ :math:`^{-3}`"
   ":math:`K_{{\mbox{fed}}}`", "K\_Fe(1:3)", "iron half saturation constant", "1.0, 0.2, 0.1", ":math:`\mu`\ mol/m\ :math:`^{-3}`"
   ":math:`op_{min}`", "op\_dep\_min", "boundary for light attenuation", "0.1", "1"
   ":math:`chlabs`", "chlabs(1:3)", "light absorption length per chla conc.", "0.03, 0.01, 0.05", "1\ :math:`/`\ m\ :math:`/`\ (mg:math:`/`\ m\ :math:`^{3}`)"
   ":math:`\alpha`", "alpha2max\_low(1:3)", "light limitation factor", "0.25, 0.25, 0.25", "m\ :math:`^2`/W"
   ":math:`\beta`", "beta2max(1:3)", "light inhibition factor", "0.018, 0.0025, 0.01", "m\ :math:`^2`/W"
   ":math:`\mu_{max}`", "mu\_max(1:3)", "maximum algal growth rate", "1.44, 0.851, 0.851", "day\ :math:`^{-1}`"
   ":math:`\mu_T`", "grow\_Tdep(1:3)", "temperature growth factor", "0.06, 0.06, 0.06", "day\ :math:`^{-1}`"
   ":math:`f_{sal}`", "fsal", "salinity growth factor", "1", "1"
   ":math:`R_{si:n}`", "R\_Si2N(1:3)", "algal silicate to nitrogen", "1.8, 0, 0", "mol/mol"

:math:`^a` only (1:2) of DOC and DOC parameters have physical meaning

.. _bgc-hist:

Biogeochemistry History Fields
``````````````````````````````

The biogeochemical history fields specified in icefields\_bgc\_nml are
written when ‘x’ is replaced with a time interval: step (‘1’), daily
(‘d’), monthly (‘m’), or yearly (‘y’). Several of these flags turn on
multiple history variables according to the particular ecosystem
prescribed in **icepack\_in**. For example, biogeochemical fluxes from the
ice to ocean will be saved monthly in the history output if

::

    f_fbio = 'm'

However, only the biogeochemical tracers which are active will be saved.
This includes at most fNit nitrate, fAm ammonium, fN algal nitrogen,
fDOC dissolved organic carbon, fDON dissolved organic nitrogen, fFep
particulate iron, fFed dissolved iron, fSil silicate, fhum humic matter,
fPON passive mobile tracer, fDMS DMS, fDMSPd dissolved DMSP and fDMSPp
particulate DMSP.

:ref:`tab-bio-history` lists the
biogeochemical tracer history flags along with a short description and
the variable or variables saved. Not listed are flags appended with
\_ai, i.e. f\_fbio\_ai. These fields are identical to their counterpart.
i.e. f\_fbio, except they are averaged by ice area.

:ref:`tab-bio-history` :*Biogeochemical History variables*

.. _tab-bio-history:

.. csv-table:: Table 6
   :header: "History Flag", "Definition", "Variable(s)", "Units"
   :widths: 10, 25, 20, 10

   "f\_faero\_atm", "atmospheric aerosol deposition flux", "faero\_atm", "kg m\ :math:`^{-2}` s\ :math:`^{-1}`"
   "f\_faero\_ocn", "aerosol flux from ice to ocean", "faero\_ocn", "kg m\ :math:`^{-2}` s\ :math:`^{-1}`"
   "f\_aero", "aerosol mass (snow and ice ssl and int)", "aerosnossl, aerosnoint,aeroicessl, aeroiceint", "kg/kg"
   "f\_fbio", "biological ice to ocean flux", "fN, fDOC, fNit, fAm,fDON,fFep\ :math:`^a`, fFed\ :math:`^a`, fSil,fhum, fPON, fDMSPd,fDMS, fDMSPp, fzaero", "mmol m\ :math:`^{-2}` s\ :math:`^{-1}`"
   "f\_zaero", "bulk z-aerosol mass fraction", "zaero", "kg/kg"
   "f\_bgc\_S", "bulk z-salinity", "bgc\_S", "ppt"
   "f\_bgc\_N", "bulk algal N concentration", "bgc\_N", "mmol m\ :math:`^{-3}`"
   "f\_bgc\_C", "bulk algal C concentration", "bgc\_C", "mmol m\ :math:`^{-3}`"
   "f\_bgc\_DOC", "bulk DOC concentration", "bgc\_DOC", "mmol m\ :math:`^{-3}`"
   "f\_bgc\_DON", "bulk DON concentration", "bgc\_DON", "mmol m\ :math:`^{-3}`"
   "f\_bgc\_DIC", "bulk DIC concentration", "bgc\_DIC", "mmol m\ :math:`^{-3}`"
   "f\_bgc\_chl", "bulk algal chlorophyll concentration", "bgc\_chl", "mg chl m\ :math:`^{-3}`"
   "f\_bgc\_Nit", "bulk nitrate concentration", "bgc\_Nit", "mmol m\ :math:`^{-3}`"
   "f\_bgc\_Am", "bulk ammonium concentration", "bgc\_Am", "mmol m\ :math:`^{-3}`"
   "f\_bgc\_Sil", "bulk silicate concentration", "bgc\_Sil", "mmol m\ :math:`^{-3}`"
   "f\_bgc\_DMSPp", "bulk particulate DMSP concentration", "bgc\_DMSPp", "mmol m\ :math:`^{-3}`"
   "f\_bgc\_DMSPd", "bulk dissolved DMSP concentration", "bgc\_DMSPd", "mmol m\ :math:`^{-3}`"
   "f\_bgc\_DMS", "bulk DMS concentration", "bgc\_DMS", "mmol m\ :math:`^{-3}`"
   "f\_bgc\_Fe", "bulk dissolved and particulate iron conc.", "bgc\_Fed, bgc\_Fep", ":math:`\mu\,`\ mol m\ :math:`^{-3}`"
   "f\_bgc\_hum", "bulk humic matter concentration", "bgc\_hum", "mmol m\ :math:`^{-3}`"
   "f\_bgc\_PON", "bulk passive mobile tracer conc.", "bgc\_PON", "mmol m\ :math:`^{-3}`"
   "f\_upNO", "Total algal :math:`{\mbox{NO$_3$}}` uptake rate", "upNO", "mmol m\ :math:`^{-2}` d\ :math:`^{-1}`"
   "f\_upNH", "Total algal :math:`{\mbox{NH$_4$}}` uptake rate", "upNH", "mmol m\ :math:`^{-2}` d\ :math:`^{-1}`"
   "f\_bgc\_ml", "upper ocean tracer concentrations", "ml\_N, ml\_DOC, ml\_Nit,ml\_Am, ml\_DON, ml\_Fep\ :math:`^b`,ml\_Fed\ :math:`^b`, ml\_Sil, ml\_hum, ml\_PON,ml\_DMS, ml\_DMSPd, ml\_DMSPp", "mmol m\ :math:`^{-3}`"
   "f\_bTin", "ice temperature on the bio grid", "bTizn", ":math:`^o`\ C"
   "f\_bphi", "ice porosity on the bio grid", "bphizn", "%"
   "f\_iDin", "brine eddy diffusivity on the interface bio grid", "iDin", "m\ :math:`^{2}` d\ :math:`^{-1}`"
   "f\_iki", "ice permeability on the interface bio grid", "ikin", "mm\ :math:`^{2}`"
   "f\_fbri", "ratio of brine tracer height to ice thickness", "fbrine", "1"
   "f\_hbri", "brine tracer height", "hbrine", "m"
   "f\_zfswin", "internal ice PAR on the interface bio grid", "zfswin", "W m\ :math:`^{-2}`"
   "f\_bionet", "brine height integrated tracer concentration", "algalN\_net, algalC\_net, chl\_net, pFe\ :math:`^c`\ \_net, dFe\ :math:`^c`\ \_net, Sil\_net, Nit\_net, Am\_net, hum\_net, PON\_net, DMS\_net, DMSPd\_net, DMSPp\_net, DOC\_net, zaero\_net, DON\_net", "mmol m\ :math:`^{-2}`"
   "f\_biosnow", snow integrated tracer concentration", "algalN\_snow, algalC\_snow,chl\_snow, pFe\ :math:`^c`\ \_snow, dFe\ :math:`^c`\ \_snow,Sil\_snow, Nit\_snow, Am\_snow, hum\_snow, PON\_snow, DMS\_snow, DMSPd\_snow, DMSPp\_snow, DOC\_snow, zaero\_snow, DON\_snow", "mmol m\ :math:`^{-2}`"
   "f\_grownet", "Net specific algal growth rate", "grow\_net", "m d\ :math:`^{-1}`"
   "f\_PPnet", "Net primary production", "PP\_net", "mgC m\ :math:`^{-2}` d\ :math:`^{-1}`"
   "f\_algalpeak", "interface bio grid level of peak chla", "peak\_loc", "1"
   "f\_zbgc\_frac", "mobile fraction of tracer", "algalN\_frac, chl\_frac, pFe\_frac,dFe\_frac, Sil\_frac, Nit\_frac,Am\_frac, hum\_frac, PON\_frac,DMS\_frac, DMSPd\_frac, DMSPp\_frac,DOC\_frac, zaero\_frac, DON\_frac", "1"


:math:`^a` units are :math:`\mu`\ mol m\ :math:`^{-2}` s\ :math:`^{-1}`

:math:`^b` units are :math:`\mu`\ mol m\ :math:`^{-3}`

:math:`^c` units are :math:`\mu`\ mol m\ :math:`^{-2}`


.. _tracer-numerics:

Flux-Corrected, Positive Definite Transport Scheme
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Numerical solution of the vertical tracer transport equation is
accomplished using the finite element Galerkin discretization. Multiply
[eqn:mobile\_transport] by "w" and integrate by parts

.. math::
   \begin{aligned}
   & & \int_{h}\left[ w\frac{\partial C}{\partial t} -   \frac{\partial
       w}{\partial x} \left(-\left[\frac{v}{h} + \frac{w_f}{h\phi}\right]C + \frac{D_{in}}{\phi^2}\frac{\partial
         \phi}{\partial x}C  -  \frac{D_{in}}{\phi}\frac{\partial C}{\partial
         x} \right) \right]dx \nonumber \\
   & + &  w\left.\left(
       -\left[\frac{1}{h}\frac{dh_b}{dt}+  \frac{w_f}{h\phi}\right]C + \frac{D_{in}}{\phi^2}\frac{\partial \phi}{\partial
       x}C -\frac{D_{in}}{\phi}\frac{\partial C}{\partial
       x}\right)\right|_{bottom} + w\left[\frac{1}{h}\frac{dh_t}{dt} +
   \frac{w_f}{h\phi}\right]C|_{top}  =  0\end{aligned}

The bottom boundary condition indicated by :math:`|_{bottom}` satisfies

.. math::
   \begin{aligned}
   -w\left.\left(
       -\left[\frac{1}{h}\frac{dh_b}{dt}+  \frac{w_f}{h\phi}\right]C + \frac{D_{in}}{\phi^2}\frac{\partial \phi}{\partial
       x}C -\frac{D_{in}}{\phi}\frac{\partial C}{\partial
       x}\right)\right|_{bottom} & = & \nonumber \\
    w\left[\frac{1}{h}\frac{dh_b}{dt} +
   \frac{w_f}{h \phi_{N+1}}\right](C_{N+2} \mbox{ or }C_{N+1}) -
   w\frac{D_{in}}{\phi_{N+1}(\Delta h+g_o)}\left(C_{N+1} - C_{N+2}\right) & & \end{aligned}

where :math:`C_{N+2} = h\phi_{N+1}[c]_{ocean}` and :math:`w = 1` at the
bottom boundary and the top. The component :math:`C_{N+2}` or
:math:`C_{N+1}` depends on the sign of the advection boundary term. If
:math:`dh_b + w_f/\phi > 0` then use :math:`C_{N+2}` otherwise
:math:`C_{N+1}`.

Define basis functions as linear piecewise, with two nodes (boundary
nodes) in each element. Then for :math:`i > 1` and :math:`i < N+1`

.. math::
   \begin{aligned}
   w_i(x) & = & \left\{ \begin{array}{llll}
   0 & x < x_{i-1} \\
   (x - x_{i-1})/\Delta & x_{i-1}< x \leq x_{i} \\
   1 - (x-x_i)/\Delta & x_i \leq x < x_{i+1} \\
   0, & x \geq x_{i+1} 
   \end{array}
   \right.\end{aligned}

For :math:`i=1`

.. math::
   \begin{aligned}
   w_1(x) & = & \left\{ \begin{array}{ll}
   1 - x/\Delta & x < x_{2} \\
   0, & x \geq x_{2} 
   \end{array}
   \right.\end{aligned}

and :math:`i = N+1`

.. math::
   \begin{aligned}
   w_{N+1}(x) & = & \left\{ \begin{array}{ll}
   0, & x < x_{N} \\
   (x-x_{N})/\Delta & x \geq x_{N}
   \end{array}
   \right.\end{aligned}

Now assume a form

.. math::
   C_h =  \sum_j^{N+1} c_j w_j

Then

.. math::
   \begin{aligned}
   \int_h C_h dx & = & c_1\int_0^{x_{2}}\left(1-\frac{x}{\Delta}\right)dx
     +  c_{N+1}\int_{x_N}^{x_{N+1}}\frac{x-x_{N}}{\Delta}dx  \nonumber \\
   & + &
     \sum_{j=2}^{N}c_j\left\{\int_{j-1}^{j}\frac{x-x_{j-1}}{\Delta}dx +
       \int_{j}^{j+1}\left[1 - \frac{(x-x_j)}{\Delta}\right]dx\right\}
     \nonumber \\
   & = & \Delta \left[\frac{c_1}{2} + \frac{c_{N+1}}{2} + \sum_{j = 2}^{N}c_{j}\right]\end{aligned}

Now this approximate solution form is substituted into the variational
equation with :math:`w = w_h \in \{w_j\}`

.. math::
   \begin{aligned}
   0 &= & \int_{h}\left[ w_h\frac{\partial C_h}{\partial t} -   \frac{\partial
       w_h}{\partial x} \left(\left[-\frac{v}{h} - \frac{w_f}{h\phi}+ \frac{D_{in}}{\phi^2}\frac{\partial
         \phi}{\partial x}\right]C_h  -  \frac{D_{in}}{\phi}\frac{\partial C_h}{\partial
         x} \right) \right]dx \nonumber \\
   & + &  w_h\left.\left(
       -\left[\frac{1}{h}\frac{dh_b}{dt}+  \frac{w_f}{h\phi}\right]C_h + \frac{D_{in}}{\phi^2}\frac{\partial \phi}{\partial
       x}C -\frac{D_{in}}{\phi}\frac{\partial C_h}{\partial
       x}\right)\right|_{bottom} + w_h\left[\frac{1}{h}\frac{dh_t}{dt} +
   \frac{w_f}{h\phi}\right]C_h|_{top} \end{aligned}

The result is a linear matrix equation

.. math::
   M_{jk}\frac{\partial C_k(t)}{\partial t} = [K_{jk}+S_{jk}] C_k(t) + q_{in}

where

.. math::
   \begin{aligned}
   M_{jk} & = & \int_h w_j(x)w_k(x)dx \nonumber \\
   K_{jk} & = & \left[-\frac{v}{h} - \frac{w_f}{h\phi}+ \frac{D_{in}}{\phi^2}\frac{\partial
         \phi}{\partial x}\right]\int_h \frac{\partial w_j}{\partial x}
     w_k dx \nonumber \\
   &-&
   \left. w_j\left(-\left[\frac{v}{h} + \frac{w_f}{h\phi_k}\right]w_k +
       \frac{D_{in}}{\phi^2}\frac{\partial \phi_k}{\partial x} w_k - \frac{D_{in}}{\phi_k}\frac{\partial w_k}{\partial
         x}\right)\right|_{bot} \nonumber \\
   & = & -V_k\int_h \frac{\partial w_j}{\partial x} w_k dx -
   \left. w_j\left(-V_kw_k - \frac{D_{in}}{\phi_k}\frac{\partial w_k}{\partial
         x}\right)\right|_{bot} \nonumber \\
   S_{jk} & = & -\frac{D_{in}}{\phi_k}\int_h \frac{\partial w_j}{\partial x} \cdot
   \frac{\partial w_k}{\partial x}dx \nonumber \\
   q_{in} & = & -V C_{t} w_j(x)|_{t}\end{aligned}

And :math:`C_{N+2} = h\phi_{N+1}[c]_{ocean}`

For the top condition :math:`q_{in}` is applied to the upper value
:math:`C_2` when :math:`VC_t < 0`, i.e. :math:`q_{in}` is a source.

Compute the :math:`M_{jk}` integrals:

.. math::
   \begin{aligned}
   M_{jj} & = & \int_{x_{j-1}}^{x_j}\frac{(x- x_{j-1})^2}{\Delta^2}dx +
   \int_{x_{j}}^{x_{j+1}}\left[ 1-\frac{(x- x_{j})}{\Delta}\right]^2dx =
   \frac{2\Delta}{3} \ \ \ \mbox{for }1 < j < N+1 \nonumber \\
   M_{11} & = & \int_{x_{1}}^{x_{2}}\left[ 1-\frac{(x- x_{2})}{\Delta}\right]^2dx =
   \frac{\Delta}{3}   \nonumber \\
   M_{N+1,N+1} & = &\int_{x_{N}}^{x_{N+1}}\frac{(x- x_{N})^2}{\Delta^2}dx
   = \frac{\Delta}{3}\nonumber \end{aligned}

Off diagonal components:

.. math::
   \begin{aligned}
   M_{j,j+1} & = &  \int_{x_{j}}^{x_{j+1}}\left[1 - \frac{(x-
       x_{j})}{\Delta}\right]\left[ \frac{x-x_{j}}{\Delta}\right]dx =
   \frac{\Delta}{6} \ \ \ \mbox{for }j < N+1 \nonumber \\
   M_{j,j-1} & = &  \int_{x_{j-1}}^{x_{j}}\left[ \frac{x-x_{j-1}}{\Delta}\right]\left[1 - \frac{(x-
       x_{j-1})}{\Delta}\right]dx =
   \frac{\Delta}{6} \ \ \ \mbox{for }j > 1 \nonumber \\\end{aligned}

Compute the :math:`K_{jk}` integrals:

.. math::
   \begin{aligned}
   K_{jj} &=& k'_{jj}\left[ \int_{x_{j-1}}^{x_j} \frac{\partial w_j}{\partial x}
   w_j dx + \int_{x_{j}}^{x_{j+1}} \frac{\partial w_j}{\partial x}
   w_j dx \right] \nonumber \\
   &  = &  \frac{1}{2} + -\frac{1}{2} = 0  \ \ \ \mbox{for } 1 < j < N+1 \nonumber \\ 
   K_{11} & = &  -\frac{k'_{11}}{2} = \frac{1}{2}\left[\frac{v}{h} +
     \frac{w_f}{h\phi}\right] \nonumber \\
   K_{N+1,N+1}  & = & \frac{k'_{N+1,N+1}}{2} +\min\left[0, \left(\frac{1}{h}\frac{dh_b}{dt} +
   \frac{w_f}{h \phi_{N+1}}\right)\right] -
   \frac{D_{in}}{\phi_{N+1}(g_o/h)} \nonumber \\
   & = & \left[-\frac{v}{h} - \frac{w_f}{h\phi}+ \frac{D_{in}}{\phi^2}\frac{\partial
         \phi}{\partial x}\right]\frac{1}{2} +\min\left[0, \left(\frac{1}{h}\frac{dh_b}{dt} +
   \frac{w_f}{h \phi_{N+1}}\right)\right] -
   \frac{D_{in}}{\phi_{N+1}(g_o/h)} \end{aligned}

Off diagonal components:

.. math::
   \begin{aligned}
   K_{j(j+1)} &=& k'_{j(j+1)}\int_{x_{j}}^{x_{j+1}} \frac{\partial w_j}{\partial x}
   w_{j+1} dx  =
   -k'_{j(j+1)}\int_{x_{j}}^{x_{j+1}}\frac{(x-x_j)}{\Delta^2}dx \nonumber
   \\
   & = & -\frac{k'_{j(j+1)}}{\Delta^2}\frac{\Delta^2}{2} =
   -\frac{k'_{j(j+1)}}{2}  = p5*\left[\frac{v}{h} + \frac{w_f}{h\phi}- \frac{D_{in}}{\phi^2}\frac{\partial
         \phi}{\partial x}\right]_{(j+1)} \ \ \ \mbox{for }  j < N+1 \nonumber \\
   K_{j(j-1)} &=& k'_{j(j-1)}\int_{x_{j-1}}^{x_{j}} \frac{\partial w_j}{\partial x}
   w_{j-1} dx  =
   k'_{j(j-1)}\int_{x_{j-1}}^{x_{j}}\left[1 -
     \frac{(x-x_{j-1})}{\Delta^2}\right] dx \nonumber
   \\
   & = & \frac{k'_{j(j-1)}}{\Delta^2}\frac{\Delta^2}{2} =
   \frac{k'_{j(j-1)}}{2}  = -p5*\left[\frac{v}{h} + \frac{w_f}{h\phi}- \frac{D_{in}}{\phi^2}\frac{\partial
         \phi}{\partial x}\right]_{(j-1)} \ \ \ \ \ \mbox{for }  j > 1 \end{aligned}

for :math:`K_{N+1,N}`, there’s a boundary contribution .

.. math::
   K_{N+1,N} = \frac{k'_{N+1(N)}}{2} - \frac{D_N}{\Delta \phi_{N}}

Note. The bottom condition works if :math:`C_{bot} = h
\phi_{N+2}[c]_{ocean}`, :math:`\phi^2` is :math:`\phi_{N+1}\phi_{N+2}`
and

.. math::
   \begin{aligned}
   \left. \frac{\partial \phi}{\partial x}\right|_{bot} & = &
   \frac{\phi_{N+2} - \phi_{N}}{2\Delta}\end{aligned}

Then the :math:`D_{N+1}/\phi_{N+1}/\Delta` cancels properly with the
porosity gradient. In general

.. math::
   \begin{aligned}
   \left. \frac{\partial \phi}{\partial x}\right|_{k} & = &
   \frac{\phi_{k+2} - \phi_{k}}{2\Delta}\end{aligned}

When evaluating the integrals for the diffusion term, we will assume
that :math:`D/\phi` is constant in an element. For :math:`D_{in}/i\phi`
defined on interface points, :math:`D_1 = 0` for :math:`j = 2,...,N`
:math:`D_j/b\phi_j = (D_{in}(j) + D_{in}(j+1))/(i\phi_j + i\phi_{j+1})`.
Then the above integrals will be modified as follows:

Compute the :math:`S_{jk}` integrals:

.. math::
   \begin{aligned}
   S_{jj} & = & - \left[\frac{D_{j-1}}{b\phi_{j-1}} \int_{x_{j-1}}^{x_j}\left( \frac{\partial
         w_j}{\partial x}\right)^2 dx + \frac{D_{j}}{b\phi_{j}} \int_{x_{j}}^{x_{j+1}}
     \left(\frac{\partial w_j}{\partial x}\right)^2 dx \right] \nonumber
   \\
   & = & -\frac{1}{\Delta}\left[\frac{D_{j-1}}{b\phi_{j-1}} + \frac{D_{j}}{b\phi{j}}\right]\ \ \mbox{for }1 < j < N+1 \nonumber \\
   S_{11} & = & \frac{s'_{11}}{\Delta}  = 0 \nonumber \\
   S_{N+1,N+1} & = & \frac{s'_{N+1,N+1}}{\Delta} = -\frac{(D_{N})}{b\phi_{N}\Delta}\end{aligned}

Compute the off-diagonal components of :math:`S_{jk}`:

.. math::
   \begin{aligned}
   S_{j(j+1)} & = & s'_{j(j+1)}\int_{x_j}^{x_{j+1}}\frac{\partial
     w_j}{\partial x} \frac{\partial w_{j+1}}{\partial x} dx =
   -\frac{s'_{j(j+1)}}{\Delta} =
   \frac{D_{j}}{b\phi_{j}\Delta} \ \ \ \mbox{for } j < N+1
   \nonumber \\
   S_{j(j-1)} & = & s'_{j(j-1)}\int_{x_{j-1}}^{x_{j}}\frac{\partial
     w_j}{\partial x} \frac{\partial w_{j-1}}{\partial x} dx =
   -\frac{s'_{j(j-1)}}{\Delta} =
   \frac{D_{j-1}}{b\phi_{j-1}} \ \ \ \mbox{for } j > 1\end{aligned}

We assume that :math:`D/\phi^2 \partial \phi/\partial x` is constant in
the element :math:`i`. If :math:`D/\phi_j` is constant, and
:math:`\partial \phi/\partial x` is constant then both the Darcy and
:math:`D` terms go as :math:`\phi^{-1}`. Then :math:`\phi = (\phi_j -
\phi_{j-1})(x-x_j)/\Delta + \phi_j` and :math:`m = (\phi_j -
\phi_{j-1})/\Delta` and :math:`b = \phi_j - mx_j`.

The first integral contribution to the Darcy term is:

.. math::
   \begin{aligned}
   K^1_{jj} & = &
   \frac{-1}{\Delta ^2}\left(\frac{w_f}{h}-\frac{D}{\phi}\frac{\partial
       \phi}{\partial x}\right)\int_{j-1}^{j}(x-x_{j-1})\frac{1}{mx
     + b}dx \nonumber \\
   & = &-\left(\frac{w_f}{h}-\frac{D}{\phi}\frac{\partial
       \phi}{\partial x}\right) \frac{1}{\Delta^2}\left[ \int_{j-1}^{j}\frac{x}{mx + b}dx - x_{j-1}\int_{j-1}^{j}\frac{1}{mx
     + b}dx  \right] \nonumber \\
   & = &- \left(\frac{w_f}{h}-\frac{D}{\phi}\frac{\partial
       \phi}{\partial x}\right) \frac{1}{\Delta^2}\left[ \frac{mx - b\log(b + mx)}{m^2} -
     x_{j-1}\frac{\log(b+mx)}{m}\right]^{x_j}_{x_{j-1}} \nonumber \\
   & = & -\left(\frac{w_f}{h}-\frac{D}{\phi}\frac{\partial
       \phi}{\partial x}\right)\frac{1}{\Delta_{\phi}}\left[ 1 + \log \left( \frac{\phi_j}{\phi_{j-1}} \right) -
     \frac{\phi_j}{\Delta_{\phi_j}}\log \left(
       \frac{\phi_j}{\phi_{j-1}} \right)\right] \nonumber \\
   & = & -\left(\frac{w_f}{h}-\frac{D}{\phi}\frac{\partial
       \phi}{\partial x}\right)\frac{1}{\Delta_{\phi}}\left[ 1 +  \frac{\phi_{j-1}}{\Delta_{\phi}}\log \left( \frac{\phi_j}{\phi_{j-1}} \right) \right]\end{aligned}

.. math::
   \begin{aligned}
   K^2_{jj} & = & \left(\frac{w_f}{h}-\frac{D}{\phi}\frac{\partial
       \phi}{\partial x}\right)\frac{1}{\Delta}\int_{x_{j}}^{x_{j+1}}\left[1 -
     \frac{(x-x_{j})}{\Delta}\right]\frac{1}{mx+b} dx \nonumber \\
   & = & \left(\frac{w_f}{h}-\frac{D}{\phi}\frac{\partial
       \phi}{\partial x}\right)\frac{1}{\Delta}\left[\frac{
       (b+m(x_j+\Delta))\log(b+mx)-mx}{\Delta
       m^2}\right]_{x_{j}}^{x_{j+1}} \nonumber \\
   & = & \left(\frac{w_f}{h}-\frac{D}{\phi}\frac{\partial
       \phi}{\partial x}\right)\frac{1}{\Delta_{\phi}}\left[ 1 -  \frac{\phi_{j+1}}{\Delta_{\phi}}\log \left( \frac{\phi_{j+1}}{\phi_{j}} \right) \right]\end{aligned}

Now :math:`m = (\phi_{j+1}-\phi_{j})/\Delta` and
:math:`b = \phi_{j+1} -
mx_{j+1}`.

Source terms :math:`q_{bot} = q_{N+1}` and :math:`q_{top} = q_{1}` (both
positive)

.. math::
   \begin{aligned}
   q_{bot} & = &\max\left[0, \left(\frac{1}{h}\frac{dh_b}{dt} +
   \frac{w_f}{h \phi_{N+1}}\right)\right]C|_{bot} +
   \frac{D_{in}}{\phi_{N+1}(g_o/h)}C|_{bot} \nonumber \\
     C|_{bot}&= & \phi_{N+1}[c]_{ocean}\end{aligned}

where :math:`g_o` is not zero.

.. math::
   \begin{aligned}
   q_{in}&  = & -\min\left[ 0, \left(\frac{1}{h}\frac{dh_t}{dt} +
   \frac{w_f}{h\phi}\right)C|_{top} \right]  \nonumber \\
   C|_{top}& = & h [c]_o\phi_{min}\end{aligned}

Calculating the low order solution: 1) Find the lumped mass matrix
:math:`M_l = diag\{m_i\}`

.. math::
   \begin{aligned}
   m_j & = & \sum_i m_{ji} = m_{j(j+1)} + m_{j(j-1)} + m_{jj} \\
    & = & \frac{\Delta}{6} + \frac{\Delta}{6} + \frac{2\Delta}{3} =
    \Delta \ \ \ \mbox{for }1 < j < N+1 \\
   m_1 & = & m_{11} + m_{12} = \frac{\Delta}{3} + \frac{\Delta}{6} =
   \frac{\Delta}{2} \\
   m_{N+1} & = & m_{N+1,N} + m_{N+1,N+1} = \frac{\Delta}{6} + \frac{\Delta}{3} =
   \frac{\Delta}{2}\end{aligned}

2) Define artificial diffusion :math:`D_a`

.. math::
   \begin{aligned}
   d_{j,(j+1)} & = & \max\{ -k_{j(j+1)},0,-k_{(j+1)j}\} = d_{(j+1)j} \\
   d_{jj} & = & -\sum_{i\neq j} d_{ji}\end{aligned}

3) Add artificial diffusion to :math:`K`: :math:`L = K + D_a`. 4) Solve
for the low order predictor solution:

.. math::
   (M_l -\Delta t [L+S])C^{n+1} = M_l C^{n} + \Delta t q

Conservations terms for the low order solution are:

.. math::
   \begin{aligned}
   \int \left[C^{n+1} -C^{n}\right] w(x)dx & = & 
    \Delta \left[\frac{c^{n+1}_1-c^{n}_1}{2} +
      \frac{c^{n+1}_{N+1}-c^{n}_{N+1}}{2} + \sum_{j =
        2}^{N}(c^{n+1}_{j}-c^{n}_{j})\right] \nonumber \\
   &  = &   \Delta t \left[ q_{bot} +
   q_{in} + (K_{N+1,N+1}+ K_{N,N+1} )C^{n+1}_{N+1} + (K_{1,1} +
   K_{2,1})C^{n+1}_{1}\right]  \nonumber \end{aligned}

Now add the antidiffusive flux: 1) compute the F matrix using the low
order solution :math:`c^{n+1}`. Diagonal components are zero. For
:math:`i \neq j`

.. math::
   \begin{aligned}
   f_{ij} & = & m_{ij}\left[\frac{\Delta c_i}{\Delta t} - \frac{\Delta
       c_j}{\Delta t} + d_{ij}(c^{n+1}_i - c^{n+1}_j\right]\end{aligned}


