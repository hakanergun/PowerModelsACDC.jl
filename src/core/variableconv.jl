"All converter variables"
function variable_dc_converter(pm::GenericPowerModel, n::Int=pm.cnw; kwargs...)
    variable_conv_tranformer_flow(pm, n; kwargs...)
    variable_conv_reactor_flow(pm, n; kwargs...)

    variable_converter_active_power(pm, n; kwargs...)
    variable_converter_reactive_power(pm, n; kwargs...)
    variable_acside_current(pm, n; kwargs...)
    variable_dcside_power(pm, n; kwargs...)
    variable_converter_firing_angle(pm, n; kwargs...)

    variable_converter_filter_voltage(pm, n; kwargs...)
    variable_converter_internal_voltage(pm, n; kwargs...)

    variable_converter_to_grid_active_power(pm, n; kwargs...)
    variable_converter_to_grid_reactive_power(pm, n; kwargs...)
end

function variable_conv_tranformer_flow(pm::GenericPowerModel, n::Int=pm.cnw; kwargs...)
    variable_conv_transformer_active_power_to(pm, n; kwargs...)
    variable_conv_transformer_reactive_power_to(pm, n; kwargs...)
end

function variable_conv_reactor_flow(pm::GenericPowerModel, n::Int=pm.cnw; kwargs...)
    variable_conv_reactor_active_power_from(pm, n; kwargs...)
    variable_conv_reactor_reactive_power_from(pm, n; kwargs...)
end



"variable: `pconv_ac[j]` for `j` in `convdc`"
function variable_converter_active_power(pm::GenericPowerModel, n::Int=pm.cnw; bounded = true)
    if bounded
        pm.var[:nw][n][:pconv_ac] = @variable(pm.model,
        [i in keys(pm.ref[:nw][n][:convdc])], basename="$(n)_pconv_ac",
        lowerbound = pm.ref[:nw][n][:convdc][i]["Pacmin"],
        upperbound = pm.ref[:nw][n][:convdc][i]["Pacmax"]
        )
    else
        pm.var[:nw][n][:pconv_ac] = @variable(pm.model,
        [i in keys(pm.ref[:nw][n][:convdc])], basename="$(n)_pconv_ac",
        start = PowerModels.getstart(pm.ref[:nw][n][:convdc], i, "P_g")
        )
    end
end

"variable: `qconv_ac[j]` for `j` in `convdc`"
function variable_converter_reactive_power(pm::GenericPowerModel, n::Int=pm.cnw; bounded = true)
    if bounded
        pm.var[:nw][n][:qconv_ac] = @variable(pm.model,
        [i in keys(pm.ref[:nw][n][:convdc])], basename="$(n)_qconv_ac",
        lowerbound = pm.ref[:nw][n][:convdc][i]["Qacmin"],
        upperbound = pm.ref[:nw][n][:convdc][i]["Qacmax"]
        )
    else
        pm.var[:nw][n][:qconv_ac] = @variable(pm.model,
        [i in keys(pm.ref[:nw][n][:convdc])], basename="$(n)_qconv_ac",
        start = PowerModels.getstart(pm.ref[:nw][n][:convdc], i, "Q_g")
        )
    end
end


"variable: `pconv_grid_ac_to[j]` for `j` in `convdc`"
function variable_conv_transformer_active_power_to(pm::GenericPowerModel, n::Int=pm.cnw; bounded = true)
    bigM = 2;
    if bounded
        pm.var[:nw][n][:pconv_tf_to] = @variable(pm.model,
        [i in keys(pm.ref[:nw][n][:convdc])], basename="$(n)_pconv_tf_to",
#        lowerbound = pm.ref[:nw][n][:convdc][i]["Pacmin"],
        lowerbound = -pm.ref[:nw][n][:convdc][i]["Pacrated"] * bigM,
        upperbound =  pm.ref[:nw][n][:convdc][i]["Pacrated"] * bigM
        )
    else
        pm.var[:nw][n][:pconv_tf_to] = @variable(pm.model,
        [i in keys(pm.ref[:nw][n][:convdc])], basename="$(n)_pconv_tf_to",
        start = PowerModels.getstart(pm.ref[:nw][n][:convdc], i, "P_g")
        )
    end
end

"variable: `qconv_grid_ac_to[j]` for `j` in `convdc`"
function variable_conv_transformer_reactive_power_to(pm::GenericPowerModel, n::Int=pm.cnw; bounded = true)
    bigM = 2;
    if bounded
        pm.var[:nw][n][:qconv_tf_to] = @variable(pm.model,
        [i in keys(pm.ref[:nw][n][:convdc])], basename="$(n)_qconv_tf_to",
        lowerbound = -pm.ref[:nw][n][:convdc][i]["Qacrated"] * bigM,
        upperbound =  pm.ref[:nw][n][:convdc][i]["Qacrated"] * bigM
        )
    else
        pm.var[:nw][n][:qconv_tf_to] = @variable(pm.model,
        [i in keys(pm.ref[:nw][n][:convdc])], basename="$(n)_qconv_tf_to",
        start = PowerModels.getstart(pm.ref[:nw][n][:convdc], i, "Q_g")
        )
    end
end


"variable: `pconv_pr_from[j]` for `j` in `convdc`"
function variable_conv_reactor_active_power_from(pm::GenericPowerModel, n::Int=pm.cnw; bounded = true)
    bigM = 2
    if bounded
        pm.var[:nw][n][:pconv_pr_fr] = @variable(pm.model,
        [i in keys(pm.ref[:nw][n][:convdc])], basename="$(n)_pconv_pr_from",
        lowerbound = -pm.ref[:nw][n][:convdc][i]["Pacrated"] * bigM,
        upperbound =  pm.ref[:nw][n][:convdc][i]["Pacrated"] * bigM #TODO derive maximum losses
        )
    else
        pm.var[:nw][n][:pconv_pr_fr] = @variable(pm.model,
        [i in keys(pm.ref[:nw][n][:convdc])], basename="$(n)_pconv_pr_from",
        start = PowerModels.getstart(pm.ref[:nw][n][:convdc], i, "P_g")
        )
    end
end

"variable: `qconv_pr_from[j]` for `j` in `convdc`"
function variable_conv_reactor_reactive_power_from(pm::GenericPowerModel, n::Int=pm.cnw; bounded = true)
    bigM = 2
    if bounded
        pm.var[:nw][n][:qconv_pr_fr] = @variable(pm.model,
        [i in keys(pm.ref[:nw][n][:convdc])], basename="$(n)_qconv_pr_from",
        lowerbound = -pm.ref[:nw][n][:convdc][i]["Qacrated"] * bigM,
        upperbound =  pm.ref[:nw][n][:convdc][i]["Qacrated"] * bigM #TODO derive maximum losses
        )
    else
        pm.var[:nw][n][:qconv_pr_fr] = @variable(pm.model,
        [i in keys(pm.ref[:nw][n][:convdc])], basename="$(n)_qconv_pr_from",
        start = PowerModels.getstart(pm.ref[:nw][n][:convdc], i, "Q_g")
        )
    end
end



"variable: `pconv_grid_ac[j]` for `j` in `convdc`"
function variable_converter_to_grid_active_power(pm::GenericPowerModel, n::Int=pm.cnw; bounded = true)
    bigM = 2
    if bounded
        pm.var[:nw][n][:pconv_tf_fr] = @variable(pm.model,
        [i in keys(pm.ref[:nw][n][:convdc])], basename="$(n)_pconv_tf_fr",
        lowerbound = -pm.ref[:nw][n][:convdc][i]["Pacrated"] * bigM,
        upperbound =  pm.ref[:nw][n][:convdc][i]["Pacrated"] * bigM #TODO derive maximum losses
        )
    else
        pm.var[:nw][n][:pconv_tf_fr] = @variable(pm.model,
        [i in keys(pm.ref[:nw][n][:convdc])], basename="$(n)_pconv_tf_fr",
        start = PowerModels.getstart(pm.ref[:nw][n][:convdc], i, "P_g")
        )
    end
end

"variable: `qconv_grid_ac[j]` for `j` in `convdc`"
function variable_converter_to_grid_reactive_power(pm::GenericPowerModel, n::Int=pm.cnw; bounded = true)
    bigM = 2
    if bounded
        pm.var[:nw][n][:qconv_tf_fr] = @variable(pm.model,
        [i in keys(pm.ref[:nw][n][:convdc])], basename="$(n)_qconv_tf_fr",
        lowerbound = -pm.ref[:nw][n][:convdc][i]["Qacrated"] * bigM,
        upperbound =  pm.ref[:nw][n][:convdc][i]["Qacrated"] * bigM #TODO derive maximum losses
        )
    else
        pm.var[:nw][n][:qconv_tf_fr] = @variable(pm.model,
        [i in keys(pm.ref[:nw][n][:convdc])], basename="$(n)_qconv_tf_fr",
        start = PowerModels.getstart(pm.ref[:nw][n][:convdc], i, "Q_g")
        )
    end
end


"variable: `pconv_dc[j]` for `j` in `convdc`"
function variable_dcside_power(pm::GenericPowerModel, n::Int=pm.cnw; bounded = true)
    bigM = 1.2; # to account for losses, maximum losses to be derived
    if bounded
        pm.var[:nw][n][:pconv_dc] = @variable(pm.model,
        [i in keys(pm.ref[:nw][n][:convdc])], basename="$(n)_pconv_dc",
        lowerbound = -pm.ref[:nw][n][:convdc][i]["Pacrated"] * bigM,
        upperbound =  pm.ref[:nw][n][:convdc][i]["Pacrated"] * bigM #TODO derive maximum losses
        )
    else
        pm.var[:nw][n][:pconv_dc] = @variable(pm.model,
        [i in keys(pm.ref[:nw][n][:convdc])], basename="$(n)_pconv_dc",
        start = PowerModels.getstart(pm.ref[:nw][n][:convdc], i, "Pdcset")
        )
    end
end

"variable: `pconv_dc[j]` for `j` in `convdc`"
function variable_converter_firing_angle(pm::GenericPowerModel, n::Int=pm.cnw; bounded = true)
    if bounded
        pm.var[:nw][n][:phiconv] = @variable(pm.model,
        [i in keys(pm.ref[:nw][n][:convdc])], basename="$(n)_phiconv",
        lowerbound = 0,
        upperbound =  pi
        )
    else
        pm.var[:nw][n][:phiconv] = @variable(pm.model,
        [i in keys(pm.ref[:nw][n][:convdc])], basename="$(n)_phiconv",
        start =  acos( PowerModels.getstart(pm.ref[:nw][n][:convdc], i, "Pdcset") / sqrt(PowerModels.getstart(pm.ref[:nw][n][:convdc], i, "Pacrated")^2 + PowerModels.getstart(pm.ref[:nw][n][:convdc], i, "Qacrated")^2) )
        )
    end
end
# "variable: `iconv_ac[j]` for `j` in `convdc`"
# function variable_acside_current(pm::GenericPowerModel, n::Int=pm.cnw; bounded = true)
#     pm.var[:nw][n][:iconv_ac] = @variable(pm.model,
#     [i in keys(pm.ref[:nw][n][:convdc])], basename="$(n)_iconv_ac",
#     lowerbound = 0,
#     upperbound = sqrt(pm.ref[:nw][n][:convdc][i]["Pacrated"]^2 + pm.ref[:nw][n][:convdc][i]["Qacmax"]^2) / sqrt(3) # assuming rated voltage = 1pu
#     )
# end

"variable: `iconv_ac[j]` for `j` in `convdc`"
function variable_acside_current(pm::GenericPowerModel, n::Int=pm.cnw; bounded = true)
    pm.var[:nw][n][:iconv_ac] = @variable(pm.model,
    [i in keys(pm.ref[:nw][n][:convdc])], basename="$(n)_iconv_ac",
    lowerbound = 0,
    upperbound = pm.ref[:nw][n][:convdc][i]["Imax"]
    )
end

"variable: `iconv_ac[j]` and `iconv_ac_sq[j]` for `j` in `convdc`"
function variable_acside_current(pm::GenericPowerModel{T}, n::Int=pm.cnw; bounded = true) where {T <: PowerModels.AbstractWForms}
    pm.var[:nw][n][:iconv_ac] = @variable(pm.model,
    [i in keys(pm.ref[:nw][n][:convdc])], basename="$(n)_iconv_dc",
    lowerbound = 0,
    upperbound = pm.ref[:nw][n][:convdc][i]["Imax"]
    )
    pm.var[:nw][n][:iconv_ac_sq] = @variable(pm.model,
    [i in keys(pm.ref[:nw][n][:convdc])], basename="$(n)_iconv_dc_sq",
    lowerbound = 0,
    upperbound = pm.ref[:nw][n][:convdc][i]["Imax"]^2
    )
end

"variable: `itf_sq[j]` for `j` in `convdc`"
function variable_conv_transformer_current_sqr(pm::GenericPowerModel{T}, n::Int=pm.cnw; bounded = true) where {T <: PowerModels.AbstractWForms}
    bigM = 2 #TODO derive exact bound
    pm.var[:nw][n][:itf_sq] = @variable(pm.model,
    [i in keys(pm.ref[:nw][n][:convdc])], basename="$(n)_itf_sq",
    lowerbound = 0,
    upperbound = (bigM*pm.ref[:nw][n][:convdc][i]["Imax"])^2
    )
end


"variable: `irc_sq[j]` for `j` in `convdc`"
function variable_conv_reactor_current_sqr(pm::GenericPowerModel{T}, n::Int=pm.cnw; bounded = true) where {T <: PowerModels.AbstractWForms}
    bigM = 2 #TODO derive exact bound
    pm.var[:nw][n][:irc_sq] = @variable(pm.model,
    [i in keys(pm.ref[:nw][n][:convdc])], basename="$(n)_irc_sq",
    lowerbound = 0,
    upperbound = (bigM*pm.ref[:nw][n][:convdc][i]["Imax"])^2
    )
end


function variable_converter_filter_voltage(pm::GenericPowerModel, n::Int=pm.cnw; kwargs...)
    variable_converter_filter_voltage_magnitude(pm, n; kwargs...)
    variable_converter_filter_voltage_angle(pm, n; kwargs...)
end


"variable: `vmf[j]` for `j` in `convdc`"
function variable_converter_filter_voltage_magnitude(pm::GenericPowerModel, n::Int=pm.cnw; bounded = true)
    bigM = 1.2; # only internal converter voltage is strictly regulated
    pm.var[:nw][n][:vmf] = @variable(pm.model,
    [i in keys(pm.ref[:nw][n][:convdc])], basename="$(n)_vmf",
    lowerbound = pm.ref[:nw][n][:convdc][i]["Vmmin"]/bigM,
    upperbound = pm.ref[:nw][n][:convdc][i]["Vmmax"]*bigM
    )
end


"variable: `vaf[j]` for `j` in `convdc`"
function variable_converter_filter_voltage_angle(pm::GenericPowerModel, n::Int=pm.cnw; bounded = true)
    bigM = 2*pi; #
    pm.var[:nw][n][:vaf] = @variable(pm.model,
    [i in keys(pm.ref[:nw][n][:convdc])], basename="$(n)_vaf",
    lowerbound = -bigM,
    upperbound = bigM
    )
end


function variable_converter_internal_voltage(pm::GenericPowerModel, n::Int=pm.cnw; kwargs...)
    variable_converter_internal_voltage_magnitude(pm, n; kwargs...)
    variable_converter_internal_voltage_angle(pm, n; kwargs...)
end


"variable: `vmc[j]` for `j` in `convdc`"
function variable_converter_internal_voltage_magnitude(pm::GenericPowerModel, n::Int=pm.cnw; bounded = true)
    pm.var[:nw][n][:vmc] = @variable(pm.model,
    [i in keys(pm.ref[:nw][n][:convdc])], basename="$(n)_vmc",
    lowerbound = pm.ref[:nw][n][:convdc][i]["Vmmin"],
    upperbound = pm.ref[:nw][n][:convdc][i]["Vmmax"]
    )
end

"variable: `vac[j]` for `j` in `convdc`"
function variable_converter_internal_voltage_angle(pm::GenericPowerModel, n::Int=pm.cnw; bounded = true)
    bigM = 2*pi; #
    pm.var[:nw][n][:vac] = @variable(pm.model,
    [i in keys(pm.ref[:nw][n][:convdc])], basename="$(n)_vac",
    lowerbound = -bigM,
    upperbound = bigM
    )
end



"variable: `wrf_ac[j]` and `wif_ac`  for `j` in `convdc`"
function variable_converter_filter_voltage_cross_products(pm::GenericPowerModel, n::Int=pm.cnw; bounded = true)
    bigM = 1.2; # only internal converter voltage is strictly regulated
    pm.var[:nw][n][:wrf_ac] = @variable(pm.model,
    [i in keys(pm.ref[:nw][n][:convdc])], basename="$(n)_wrf_ac",
    lowerbound = 0,
    upperbound = (pm.ref[:nw][n][:convdc][i]["Vmmax"]*bigM)^2
    )
    pm.var[:nw][n][:wif_ac] = @variable(pm.model,
    [i in keys(pm.ref[:nw][n][:convdc])], basename="$(n)_wif_ac",
    lowerbound = -(pm.ref[:nw][n][:convdc][i]["Vmmax"]*bigM)^2,
    upperbound = (pm.ref[:nw][n][:convdc][i]["Vmmax"]*bigM)^2
    )
end

"variable: `wf_ac` for `j` in `convdc`"
function variable_converter_filter_voltage_magnitude_sqr(pm::GenericPowerModel, n::Int=pm.cnw; bounded = true)
    bigM = 1.2; # only internal converter voltage is strictly regulated
    pm.var[:nw][n][:wf_ac] = @variable(pm.model,
    [i in keys(pm.ref[:nw][n][:convdc])], basename="$(n)_wf_ac",
    lowerbound = (pm.ref[:nw][n][:convdc][i]["Vmmin"]/bigM)^2,
    upperbound = (pm.ref[:nw][n][:convdc][i]["Vmmax"]*bigM)^2
    )
end


"variable: `wrc_ac[j]` and `wic_ac[j]`  for `j` in `convdc`"
function variable_converter_internal_voltage_cross_products(pm::GenericPowerModel, n::Int=pm.cnw; bounded = true)
    bigM = 1.2; # only internal converter voltage is strictly regulated
    pm.var[:nw][n][:wrc_ac] = @variable(pm.model,
    [i in keys(pm.ref[:nw][n][:convdc])], basename="$(n)_wrc_ac",
    lowerbound = 0,
    upperbound = (pm.ref[:nw][n][:convdc][i]["Vmmax"]*bigM)^2
    )
    pm.var[:nw][n][:wic_ac] = @variable(pm.model,
    [i in keys(pm.ref[:nw][n][:convdc])], basename="$(n)_wic_ac",
    lowerbound = -(pm.ref[:nw][n][:convdc][i]["Vmmax"]*bigM)^2,
    upperbound = (pm.ref[:nw][n][:convdc][i]["Vmmax"]*bigM)^2
    )
end

"variable: `wc_ac[j]` for `j` in `convdc`"
function variable_converter_internal_voltage_magnitude_sqr(pm::GenericPowerModel, n::Int=pm.cnw; bounded = true)
    pm.var[:nw][n][:wc_ac] = @variable(pm.model,
    [i in keys(pm.ref[:nw][n][:convdc])], basename="$(n)_wc_ac",
    lowerbound = (pm.ref[:nw][n][:convdc][i]["Vmmin"])^2,
    upperbound = (pm.ref[:nw][n][:convdc][i]["Vmmax"])^2
    )
end