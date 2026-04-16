function script.update(dt)
    local carId = ac.getSim().focusedCar
    ac.getCar(carId).maxFuel = 2
end