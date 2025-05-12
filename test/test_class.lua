-- Unit tests for Class.lua.

require('Class')


-- Create the namespace/module.
local M = {}


------------------- Test classes -----------------------------------
local Animal = Class(
    function(a, name)
        a.name = name
    end)

function Animal:__tostring()    
    return self.name..': '..self:speak()
end

---------- create
Dog = Class(Animal)

function Dog:speak()
    return 'bark'
end

---------- inherit
Cat = Class(Animal,
    function(c, name, breed)
        Animal.__init(c, name) -- must init base!
        c.breed = breed
    end)

function Cat:speak()
    return 'meow'
end

---------- create
Lion = Class(Cat)

function Lion:speak()
    return 'roar'
end


-- -----------------------------------------------------------------------------
-- function M.setup(pn)
--     -- pn.UT_INFO("setup()!!!")
-- end

-- -----------------------------------------------------------------------------
-- function M.teardown(pn)
--     -- pn.UT_INFO("teardown()!!!")
-- end

-----------------------------------------------------------------------------
function M.suite_class(pn)
    -- Test all functions in class.lua

    local fido = Dog('Fido')
    local felix = Cat('Felix', 'Tabby')
    local leo = Lion('Leo', 'African')

    pn.UT_STR_EQUAL(tostring(fido), "Fido: bark")
    pn.UT_STR_EQUAL(tostring(felix), "Felix: meow")
    pn.UT_STR_EQUAL(tostring(leo), "Leo: roar")
    pn.UT_TRUE(leo:is_a(Animal))
    pn.UT_FALSE(leo:is_a(Dog))
    pn.UT_TRUE(leo:is_a(Cat))

end

-----------------------------------------------------------------------------
-- Return the module.
return M
