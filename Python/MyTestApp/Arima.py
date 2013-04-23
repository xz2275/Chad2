# import numpy as np
# from scipy import signal, optimize

class ARIMA(object):
    '''currently ARMA only, no differencing used - no I
    
    parameterized as
         rhoy(L) y_t = rhoe(L) eta_t

    A instance of this class preserves state, so new class instances should
    be created for different examples
    '''
    def __init__(self):
        pass
    def fit(self,x,p,q):
        '''estimate lag coefficients of ARMA orocess by least squares
        
        Parameters
        ----------
            x : array, 1d
                time series data 
            p : int
                number of AR lags to estimate
            q : int
                number of MA lags to estimate
            rhoy0, rhoe0 : array_like (optional)
                starting values for estimation
                
        Returns
        -------
            rh, cov_x, infodict, mesg, ier : output of scipy.optimize.leastsq
            rh :
                estimate of lag parameters, concatenated [rhoy, rhoe]
            cov_x :
                unscaled (!) covariance matrix of coefficient estimates
        
        
        '''
        rhoy0 = [0.5] * p 
        rhoe0 = [0.5] * q
        
        def concatenate((a, b)):
            # a is a number like [1], b is an array rho[:p]
            length = len(b) + 1
            result = [0] * length
            for i in xrange(1, length):
                result[i] = b[i-1]
            result[0] = a[0]
            return result
        
        def errfn( rho):
            #rhoy, rhoe = rho
            rhoy = concatenate(([1], rho[:p]))
            rhoe = concatenate(([1], rho[p:]))
            etahatr = signal.lfilter(rhoy, rhoe, x)
            #print rho,np.sum(etahatr*etahatr)
            return etahatr    
        usels = True
        if usels:
            rh, cov_x, infodict, mesg, ier = \
               optimize.leastsq(errfn, np.r_[rhoy0, rhoe0],ftol=1e-10,full_output=True)
        else:
            # fmin_bfgs is slow or doesn't work yet
            errfnsum = lambda rho : np.sum(errfn(rho)**2)
            #xopt, {fopt, gopt, Hopt, func_calls, grad_calls
            rh,fopt, gopt, cov_x, _,_, ier = \
                optimize.fmin_bfgs(errfnsum, np.r_[rhoy0, rhoe0], maxiter=2, full_output=True)
            infodict, mesg = None, None
        self.rh = rh
        self.rhoy = concatenate(([1], rh[:p]))
        self.rhoe = concatenate(([1], rh[p:])) #rh[-q:])) doesnt work for q=0
        self.error_estimate = errfn(rh)
        return rh, cov_x, infodict, mesg, ier
        
    def errfn(self, rho=None, p=None, x=None):
        ''' duplicate -> remove one
        '''
        #rhoy, rhoe = rho
        if not rho is None:
            rhoy = concatenate(([1],  rho[:p]))
            rhoe = concatenate(([1],  rho[p:]))
        else:
            rhoy = self.rhoy
            rhoe = self.rhoe         
        etahatr = signal.lfilter(rhoy, rhoe, x)
        #print rho,np.sum(etahatr*etahatr)
        return etahatr
        
    def predicted(self, rhoy=None, rhoe=None):
        '''past predicted values of time series 
        just added, not checked yet
        '''
        if rhoy is None:
            rhoy = self.rhoy
        if rhoe is None:
            rhoe = self.rhoe
        return self.x + self.error_estimate
        
    def forecast(self, ar=None, ma=None, nperiod=10):
        eta = np.r_[self.error_estimate, np.zeros(nperiod)]
        if ar is None:
            ar = self.rhoy
        if ma is None:
            ma = self.rhoe
        return signal.lfilter(ma, ar, eta)
    
def concatenate((a, b)):
            # a is a number like [1], b is an array rho[:p]
            length = len(b) + 1
            result = [0] * length
            for i in xrange(1, length):
                result[i] = b[i-1]
            result[0] = a[0]
            return result   
