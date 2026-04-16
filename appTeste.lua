function script.update(dt)
    local carId = ac.getSim().focusedCar
    ac.getCar(carId).turboBoost = 100
end