function script.update(dt)
    local carId = ac.getSim().focusedCar
    ac.getCar(carId).bodyHeight = 0.5
end